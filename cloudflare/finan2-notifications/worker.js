// Relays a single push notification to every device of a Finan2 household,
// except the device(s) belonging to whoever triggered it (they already see
// the change live in the app). Stateless: reads tokens from Firestore on
// every call, no KV/D1 involved.
//
// Auth model: the caller sends its Firebase ID token (Authorization: Bearer).
// The Worker verifies its signature against Google's public keys and only
// relays to a household the token's uid is a member of - nothing secret ships
// inside the app. The push itself is sent as a Google service account, whose
// private key is minted into a short-lived OAuth token per request.
//
// This Worker also runs a Cron Trigger (see wrangler.toml) that fires the
// reminders `NotificationService` schedules locally on native platforms
// (daily/weekly/debt payment) - flutter_local_notifications has no real
// background-scheduling equivalent on web, so those reminders have to come
// from somewhere with its own clock. See handleScheduled() below.

const ICON_URL = 'https://finan2.web.app/icons/Icon-192.png';

// Colombia is UTC-5 year-round (no DST) - this whole file assumes that
// single fixed offset rather than pulling in a timezone library.
const CO_UTC_OFFSET_HOURS = 5;

// The web build calls this cross-origin; native apps don't send an Origin.
const ALLOWED_ORIGINS = ['https://finan2.web.app', 'https://finan2.firebaseapp.com'];

const MAX_TITLE_LENGTH = 120;
const MAX_BODY_LENGTH = 400;

export default {
  async fetch(request, env) {
    const cors = corsHeaders(request);
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: cors });
    }
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405, headers: cors });
    }

    const projectId = env.FIREBASE_PROJECT_ID;
    const authHeader = request.headers.get('Authorization') ?? '';
    const idToken = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
    let uid;
    try {
      uid = idToken ? await verifyFirebaseIdToken(idToken, projectId) : null;
    } catch (e) {
      console.warn(`ID token rejected: ${e.message}`);
      uid = null;
    }
    if (!uid) {
      return new Response('Unauthorized', { status: 401, headers: cors });
    }

    if (env.PUSH_LIMITER) {
      const { success } = await env.PUSH_LIMITER.limit({ key: uid });
      if (!success) return new Response('Too many requests', { status: 429, headers: cors });
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return new Response('Invalid JSON', { status: 400, headers: cors });
    }

    const { householdId, title, body: notifBody, excludeUid } = body;
    if (
      typeof householdId !== 'string' ||
      !/^[A-Za-z0-9]{1,40}$/.test(householdId) ||
      typeof title !== 'string' ||
      typeof notifBody !== 'string' ||
      !title ||
      !notifBody
    ) {
      return new Response('Missing householdId, title or body', { status: 400, headers: cors });
    }
    if (title.length > MAX_TITLE_LENGTH || notifBody.length > MAX_BODY_LENGTH) {
      return new Response('Title or body too long', { status: 400, headers: cors });
    }

    try {
      const accessToken = await getAccessToken(env.FIREBASE_SERVICE_ACCOUNT);

      const members = await getHouseholdMembers(accessToken, projectId, householdId);
      if (!members.includes(uid)) {
        return new Response('Forbidden', { status: 403, headers: cors });
      }
      // Whoever triggered it - the caller by default, or the partner when
      // the caller's device is relaying the partner's activity.
      const skipUid = members.includes(excludeUid) ? excludeUid : uid;

      const allTokens = await getHouseholdTokens(accessToken, projectId, householdId);
      // Tokens of someone who left the household never get its pushes.
      const tokens = allTokens.filter((t) => members.includes(t.uid) && t.uid !== skipUid);

      const results = await Promise.allSettled(
        tokens.map(({ token, platform }) =>
          sendToToken({ title, body: notifBody, accessToken, projectId, token, platform }),
        ),
      );
      for (const r of results) {
        if (r.status === 'rejected') console.error(r.reason?.message ?? r.reason);
      }

      return Response.json(
        {
          tokensSent: tokens.length,
          errors: results.filter((r) => r.status === 'rejected').length,
        },
        { headers: cors },
      );
    } catch (e) {
      console.error(e);
      return Response.json({ error: 'Internal error' }, { status: 500, headers: cors });
    }
  },

  async scheduled(event, env, ctx) {
    ctx.waitUntil(handleScheduled(env));
  },
};

function corsHeaders(request) {
  const origin = request.headers.get('Origin');
  if (!origin || !ALLOWED_ORIGINS.includes(origin)) return {};
  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Authorization, Content-Type',
    'Access-Control-Max-Age': '86400',
    Vary: 'Origin',
  };
}

// Google's public keys for Firebase ID tokens, cached for as long as the
// response's Cache-Control allows (per isolate).
const FIREBASE_JWKS_URL =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';
let jwksCache = { keys: null, expiresAt: 0, fetchedAt: 0 };
const JWKS_MIN_REFETCH_MS = 60 * 1000;

async function getFirebasePublicKeys() {
  if (jwksCache.keys && Date.now() < jwksCache.expiresAt) return jwksCache.keys;
  const res = await fetch(FIREBASE_JWKS_URL);
  if (!res.ok) throw new Error(`JWKS fetch failed: ${res.status}`);
  const { keys } = await res.json();
  const maxAge = /max-age=(\d+)/.exec(res.headers.get('Cache-Control') ?? '');
  jwksCache = {
    keys,
    fetchedAt: Date.now(),
    expiresAt: Date.now() + (maxAge ? parseInt(maxAge[1], 10) : 3600) * 1000,
  };
  return keys;
}

function b64urlToBytes(s) {
  const b64 = s.replace(/-/g, '+').replace(/_/g, '/');
  const padded = b64 + '='.repeat((4 - (b64.length % 4)) % 4);
  return Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
}

function b64urlToJson(s) {
  return JSON.parse(new TextDecoder().decode(b64urlToBytes(s)));
}

/// Verifies a Firebase Auth ID token as documented in
/// https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library
/// and returns its uid. Throws on anything off.
async function verifyFirebaseIdToken(token, projectId) {
  const parts = token.split('.');
  if (parts.length !== 3) throw new Error('malformed token');
  const [headerB64, payloadB64, signatureB64] = parts;
  const header = b64urlToJson(headerB64);
  const payload = b64urlToJson(payloadB64);

  if (header.alg !== 'RS256' || !header.kid) throw new Error('bad header');
  const now = Math.floor(Date.now() / 1000);
  const skew = 300;
  if (typeof payload.exp !== 'number' || payload.exp <= now) throw new Error('expired');
  if (typeof payload.iat !== 'number' || payload.iat > now + skew) throw new Error('bad iat');
  if (typeof payload.auth_time !== 'number' || payload.auth_time > now + skew) {
    throw new Error('bad auth_time');
  }
  if (payload.aud !== projectId) throw new Error('bad aud');
  if (payload.iss !== `https://securetoken.google.com/${projectId}`) throw new Error('bad iss');
  if (typeof payload.sub !== 'string' || !payload.sub || payload.sub.length > 128) {
    throw new Error('bad sub');
  }

  let jwk = (await getFirebasePublicKeys()).find((k) => k.kid === header.kid);
  if (!jwk && Date.now() - jwksCache.fetchedAt > JWKS_MIN_REFETCH_MS) {
    // Keys rotate - refetch once before giving up, but not more than once a
    // minute: this runs before auth, so a forged kid mustn't force a fetch
    // on every request.
    jwksCache.expiresAt = 0;
    jwk = (await getFirebasePublicKeys()).find((k) => k.kid === header.kid);
  }
  if (!jwk) throw new Error('unknown kid');

  const key = await crypto.subtle.importKey(
    'jwk',
    jwk,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['verify'],
  );
  const valid = await crypto.subtle.verify(
    'RSASSA-PKCS1-v1_5',
    key,
    b64urlToBytes(signatureB64),
    new TextEncoder().encode(`${headerB64}.${payloadB64}`),
  );
  if (!valid) throw new Error('bad signature');
  return payload.sub;
}

async function getHouseholdMembers(accessToken, projectId, householdId) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households/${householdId}`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  if (res.status !== 200) return [];
  const doc = await res.json();
  return (doc.fields?.members?.arrayValue?.values ?? []).map((v) => v.stringValue).filter(Boolean);
}

async function handleScheduled(env) {
  const accessToken = await getAccessToken(env.FIREBASE_SERVICE_ACCOUNT);
  const projectId = env.FIREBASE_PROJECT_ID;
  const co = coNow();
  // DRY_RUN='true' (set via `wrangler dev --test-scheduled` + .dev.vars, or
  // temporarily as a real secret) reads real data and logs what it would
  // do, but never calls FCM or writes a sentReminders marker - lets this
  // run safely against production Firestore for testing.
  const dryRun = env.DRY_RUN === 'true';
  if (dryRun) console.log(`[dry-run] co=${JSON.stringify(co)}`);

  const households = await listHouseholds(accessToken, projectId);
  if (dryRun) console.log(`[dry-run] scanning ${households.length} household(s)`);

  for (const household of households) {
    const tokens = await getHouseholdTokens(accessToken, projectId, household.id);
    if (tokens.length === 0) continue;
    const tokensByUid = {};
    for (const t of tokens) {
      (tokensByUid[t.uid] ??= []).push(t);
    }

    // Every one of these is fetched lazily, at most once per household per
    // run, and reused across every member of the household below.
    let debts = null;
    let categoriesById = null;
    let budgetOverCategoryIds = null;
    let goalAlerts = null;
    let goalsById = null;
    let partnerCreatedSources = null;

    for (const uid of household.members) {
      const memberTokens = tokensByUid[uid] ?? [];
      if (memberTokens.length === 0) continue;
      const prefs = await getMemberPrefs(accessToken, projectId, household.id, uid);

      if (prefs.dailyReminder && prefs.dailyReminderHour === co.hour) {
        await sendOnce({
          accessToken,
          dryRun,
          projectId,
          householdId: household.id,
          marker: `daily_${uid}_${co.dateStr}`,
          tokens: memberTokens,
          title: 'Registra tus gastos de hoy',
          body: 'No olvides anotar lo que ingresó o gastó el hogar hoy.',
        });
      }

      if (prefs.weeklySummary && co.weekday === 0 && co.hour === 19) {
        await sendOnce({
          accessToken,
          dryRun,
          projectId,
          householdId: household.id,
          marker: `weekly_${uid}_${co.dateStr}`,
          tokens: memberTokens,
          title: 'Resumen semanal listo',
          body: 'Revisa cómo le fue al hogar esta semana en Finan2.',
        });
      }

      if (prefs.debtPayments && co.hour === 9) {
        debts ??= await getHouseholdDebts(accessToken, projectId, household.id);
        for (const debt of debts) {
          if (!debt.hasBalance) continue;
          const daysBefore = DEBT_REMINDER_DAYS_BEFORE.find(
            (d) => co.day === debtReminderDay(debt.paymentDay, d),
          );
          if (daysBefore === undefined) continue;
          const isToday = daysBefore === 0;
          await sendOnce({
            accessToken,
            dryRun,
            projectId,
            householdId: household.id,
            // Per-day marker (not per-month) - each day of the countdown
            // gets its own notification.
            marker: `debt_${debt.id}_${uid}_${co.dateStr}`,
            tokens: memberTokens,
            title: isToday ? `Hoy pagas ${debt.name}` : `Pago de ${debt.name} pronto`,
            body: isToday
              ? `Hoy es el día de pago de tu deuda ${debt.name}.`
              : `La cuota de ${debt.name} vence en ${daysBefore} ${daysBefore === 1 ? 'día' : 'días'}.`,
          });
        }
      }

      // Amounts stay encrypted server-side - these two read a plaintext flag
      // the client already computed and persisted at write time (see
      // TransactionRepository._refreshBudgetAlert /
      // SavingsGoalRepository._refreshGoalNearAlert in the Dart app), so no
      // decryption is needed here.
      if (prefs.budgetExceeded) {
        budgetOverCategoryIds ??= await getBudgetOverCategoryIds(
          accessToken,
          projectId,
          household.id,
          co.year,
          co.month,
        );
        if (budgetOverCategoryIds.length > 0) {
          categoriesById ??= await getRawDocsById(accessToken, projectId, household.id, 'categories');
        }
        for (const categoryId of budgetOverCategoryIds) {
          const categoryName = categoriesById?.[categoryId]
            ? fieldStr(categoriesById[categoryId], 'name', 'una categoría')
            : 'una categoría';
          await sendOnce({
            accessToken,
            dryRun,
            projectId,
            householdId: household.id,
            marker: `budget_exceeded_${categoryId}_${co.monthStr}_${uid}`,
            tokens: memberTokens,
            title: 'Te pasaste del presupuesto',
            body: `${categoryName} superó lo planeado este mes.`,
          });
        }
      }

      if (prefs.goalProgress) {
        goalAlerts ??= await getGoalNearAlerts(accessToken, projectId, household.id);
        if (goalAlerts.length > 0) {
          goalsById ??= await getRawDocsById(accessToken, projectId, household.id, 'savingsGoals');
        }
        for (const goalId of goalAlerts) {
          const goalName = goalsById?.[goalId] ? fieldStr(goalsById[goalId], 'name', 'tu meta') : 'tu meta';
          await sendOnce({
            accessToken,
            dryRun,
            projectId,
            householdId: household.id,
            marker: `goal_near_${goalId}_${uid}`,
            tokens: memberTokens,
            title: '¡Casi logras tu meta!',
            body: `${goalName} está cerca de completarse.`,
          });
        }
      }

      // Nothing here needs the household's encryption key: names,
      // descriptions and createdBy are all plaintext in Firestore (only
      // amounts are encrypted) - see the README's "Cifrado de montos"
      // section for why.
      if (prefs.partnerActivity) {
        partnerCreatedSources ??= await getPartnerCreatedSources(
          accessToken,
          projectId,
          household.id,
          co.year,
          co.month,
        );
        for (const item of partnerCreatedSources) {
          if (!item.createdBy || item.createdBy === uid) continue;
          await sendOnce({
            accessToken,
            dryRun,
            projectId,
            householdId: household.id,
            marker: `partner_${item.kind}_${item.id}_${uid}`,
            tokens: memberTokens,
            title: item.title,
            body: item.body,
          });
        }

        goalsById ??= await getRawDocsById(accessToken, projectId, household.id, 'savingsGoals');
        for (const [goalId, doc] of Object.entries(goalsById)) {
          const goalName = fieldStr(doc, 'name', 'una meta');
          const contributions = (doc.fields?.contributions?.arrayValue?.values ?? [])
            .map((v) => v.mapValue?.fields)
            .filter(Boolean);
          for (const c of contributions) {
            const createdBy = c.createdBy?.stringValue;
            const date = c.date?.timestampValue;
            if (!createdBy || createdBy === uid || !date) continue;
            await sendOnce({
              accessToken,
              dryRun,
              projectId,
              householdId: household.id,
              marker: `contribution_${goalId}_${date}_${uid}`,
              tokens: memberTokens,
              title: 'Aporte registrado',
              body: `Tu pareja agregó un aporte a ${goalName}.`,
            });
          }
        }
      }
    }
  }
}

/// Mirrors NotificationService's reminder countdown (3, 2, 1, 0 días antes)
/// in lib/core/notifications/notification_service.dart.
const DEBT_REMINDER_DAYS_BEFORE = [3, 2, 1, 0];

function debtReminderDay(paymentDay, daysBefore) {
  return paymentDay - daysBefore < 1 ? 1 : paymentDay - daysBefore;
}

function coNow() {
  const shifted = new Date(Date.now() - CO_UTC_OFFSET_HOURS * 60 * 60 * 1000);
  return {
    hour: shifted.getUTCHours(),
    day: shifted.getUTCDate(),
    year: shifted.getUTCFullYear(),
    month: shifted.getUTCMonth() + 1, // 1-12, matches Dart's DateTime.month
    weekday: shifted.getUTCDay(), // 0 = Sunday
    dateStr: shifted.toISOString().slice(0, 10), // YYYY-MM-DD
    monthStr: shifted.toISOString().slice(0, 7), // YYYY-MM
  };
}

async function sendOnce({
  accessToken,
  projectId,
  householdId,
  marker,
  tokens,
  title,
  body,
  dryRun,
}) {
  const skip = await alreadySent(accessToken, projectId, householdId, marker);
  if (dryRun) {
    console.log(
      `[dry-run] ${skip ? 'SKIP (already sent)' : 'WOULD SEND'} "${title}" to ` +
        `${tokens.length} token(s), household=${householdId}, marker=${marker}`,
    );
    return;
  }
  if (skip) return;
  await Promise.allSettled(
    tokens.map((t) =>
      sendToToken({ title, body, accessToken, projectId, token: t.token, platform: t.platform }),
    ),
  );
  await markSent(accessToken, projectId, householdId, marker);
}

async function listHouseholds(accessToken, projectId) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households?pageSize=1000`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  const data = await res.json();
  if (!data.documents) return [];
  return data.documents.map((doc) => ({
    id: doc.name.split('/').pop(),
    members: (doc.fields?.members?.arrayValue?.values ?? [])
      .map((v) => v.stringValue)
      .filter(Boolean),
  }));
}

// Mirrors NotificationPrefs.defaults (lib/features/notification_prefs/data/
// notification_prefs.dart) - partnerActivity defaults to off there too.
async function getMemberPrefs(accessToken, projectId, householdId, uid) {
  const defaults = {
    dailyReminder: true,
    dailyReminderHour: 20,
    weeklySummary: true,
    debtPayments: true,
    goalProgress: true,
    budgetExceeded: true,
    partnerActivity: false,
  };
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households/${householdId}/memberPrefs/${uid}`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  if (res.status !== 200) return defaults;
  const f = (await res.json()).fields ?? {};
  return {
    dailyReminder: f.dailyReminder?.booleanValue ?? defaults.dailyReminder,
    dailyReminderHour: f.dailyReminderHour?.integerValue != null
      ? parseInt(f.dailyReminderHour.integerValue, 10)
      : defaults.dailyReminderHour,
    weeklySummary: f.weeklySummary?.booleanValue ?? defaults.weeklySummary,
    debtPayments: f.debtPayments?.booleanValue ?? defaults.debtPayments,
    goalProgress: f.goalProgress?.booleanValue ?? defaults.goalProgress,
    budgetExceeded: f.budgetExceeded?.booleanValue ?? defaults.budgetExceeded,
    partnerActivity: f.partnerActivity?.booleanValue ?? defaults.partnerActivity,
  };
}

async function getHouseholdDebts(accessToken, projectId, householdId) {
  const docs = await getRawDocs(accessToken, projectId, householdId, 'debts');
  return docs.map((doc) => ({
    id: docId(doc),
    name: fieldStr(doc, 'name'),
    paymentDay: fieldInt(doc, 'paymentDay', 1),
    hasBalance: fieldBool(doc, 'hasBalance'),
  }));
}

/// `households/{hid}/budgetAlerts/{year}_{month}`'s `overCategoryIds` -
/// written client-side by TransactionRepository._refreshBudgetAlert
/// (lib/features/transactions/data/transaction_repository.dart) whenever a
/// transaction is created/edited/deleted, since only a client with the
/// household's decryption key can compare real spend to the plan.
async function getBudgetOverCategoryIds(accessToken, projectId, householdId, year, month) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households/${householdId}/budgetAlerts/${year}_${month}`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  if (res.status !== 200) return [];
  const doc = await res.json();
  return (doc.fields?.overCategoryIds?.arrayValue?.values ?? [])
    .map((v) => v.stringValue)
    .filter(Boolean);
}

/// Goal IDs with `households/{hid}/goalAlerts/{goalId}`.near == true -
/// written client-side by SavingsGoalRepository._refreshGoalNearAlert
/// (lib/features/savings_goals/data/savings_goal_repository.dart) whenever a
/// contribution is added.
async function getGoalNearAlerts(accessToken, projectId, householdId) {
  const docs = await getRawDocs(accessToken, projectId, householdId, 'goalAlerts');
  return docs.filter((doc) => fieldBool(doc, 'near')).map(docId);
}

/// Every record across the entity types that track a `createdBy`, shaped for
/// the generic "tu pareja creó X" push - mirrors
/// NotificationScanner._scanPartnerCreated (lib/features/notifications/data/
/// notification_scanner.dart). No decryption needed: names/descriptions/
/// createdBy are all plaintext, only amounts are encrypted.
async function getPartnerCreatedSources(accessToken, projectId, householdId, year, month) {
  const [transactions, transfers, debts, accounts, investments, recurringBills, categories, savingsChallenges] =
    await Promise.all([
      getRawDocs(accessToken, projectId, householdId, 'transactions'),
      getRawDocs(accessToken, projectId, householdId, 'transfers'),
      getRawDocs(accessToken, projectId, householdId, 'debts'),
      getRawDocs(accessToken, projectId, householdId, 'accounts'),
      getRawDocs(accessToken, projectId, householdId, 'investments'),
      getRawDocs(accessToken, projectId, householdId, 'recurringBills'),
      getRawDocs(accessToken, projectId, householdId, 'categories'),
      getRawDocs(accessToken, projectId, householdId, 'savingsChallenges'),
    ]);

  const items = [];
  for (const doc of transactions) {
    if (fieldInt(doc, 'year') !== year || fieldInt(doc, 'month') !== month) continue;
    const description = fieldStr(doc, 'description');
    items.push({
      kind: 'tx',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nuevo movimiento',
      body: description || 'Tu pareja registró un movimiento.',
    });
  }
  for (const doc of transfers) {
    items.push({
      kind: 'transfer',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nueva transferencia',
      body: 'Tu pareja registró una transferencia entre cuentas.',
    });
  }
  for (const doc of debts) {
    items.push({
      kind: 'debt',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nueva deuda',
      body: fieldStr(doc, 'name'),
    });
  }
  for (const doc of accounts) {
    items.push({
      kind: 'account',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nueva cuenta',
      body: fieldStr(doc, 'name'),
    });
  }
  for (const doc of investments) {
    items.push({
      kind: 'investment',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nueva inversión',
      body: fieldStr(doc, 'name'),
    });
  }
  for (const doc of recurringBills) {
    items.push({
      kind: 'bill',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nueva factura recurrente',
      body: fieldStr(doc, 'name'),
    });
  }
  for (const doc of categories) {
    items.push({
      kind: 'category',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nueva categoría',
      body: fieldStr(doc, 'name'),
    });
  }
  for (const doc of savingsChallenges) {
    items.push({
      kind: 'challenge',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nuevo reto de ahorro',
      body: fieldStr(doc, 'name'),
    });
  }
  // savingsGoals (creation, not contributions - those are handled
  // separately in handleScheduled since they need the full doc anyway).
  const goals = await getRawDocs(accessToken, projectId, householdId, 'savingsGoals');
  for (const doc of goals) {
    items.push({
      kind: 'goal',
      id: docId(doc),
      createdBy: fieldStr(doc, 'createdBy'),
      title: 'Nueva meta de ahorro',
      body: fieldStr(doc, 'name'),
    });
  }
  return items;
}

async function getRawDocs(accessToken, projectId, householdId, collectionName) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households/${householdId}/${collectionName}?pageSize=1000`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  const data = await res.json();
  return data.documents ?? [];
}

/// Same as [getRawDocs] but keyed by document ID, for lookups (category/goal
/// names) rather than iteration.
async function getRawDocsById(accessToken, projectId, householdId, collectionName) {
  const docs = await getRawDocs(accessToken, projectId, householdId, collectionName);
  const byId = {};
  for (const doc of docs) byId[docId(doc)] = doc;
  return byId;
}

function docId(doc) {
  return doc.name.split('/').pop();
}

function fieldStr(doc, key, fallback = '') {
  return doc.fields?.[key]?.stringValue ?? fallback;
}

function fieldInt(doc, key, fallback = 0) {
  const v = doc.fields?.[key]?.integerValue;
  return v != null ? parseInt(v, 10) : fallback;
}

function fieldBool(doc, key, fallback = false) {
  return doc.fields?.[key]?.booleanValue ?? fallback;
}

async function alreadySent(accessToken, projectId, householdId, markerId) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households/${householdId}/sentReminders/${markerId}`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  return res.status === 200;
}

async function markSent(accessToken, projectId, householdId, markerId) {
  await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households/${householdId}/sentReminders?documentId=${markerId}`,
    {
      method: 'POST',
      headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ fields: { sentAt: { timestampValue: new Date().toISOString() } } }),
    },
  );
}

async function getHouseholdTokens(accessToken, projectId, householdId) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households/${householdId}/fcmTokens`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  const data = await res.json();
  if (!data.documents) return [];
  return data.documents
    .map((doc) => ({
      token: doc.fields?.token?.stringValue,
      uid: doc.fields?.uid?.stringValue,
      platform: doc.fields?.platform?.stringValue ?? 'android',
    }))
    .filter((t) => t.token);
}

async function sendToToken({ title, body, accessToken, projectId, token, platform }) {
  const isWeb = platform === 'web';
  const message = {
    token,
    notification: { title, body },
    ...(isWeb
      ? { webpush: { notification: { icon: ICON_URL, badge: ICON_URL } } }
      : {
          android: {
            notification: {
              channel_id: 'finan2_activity',
              sound: 'default',
              notification_icon: 'ic_stat_finan2',
            },
          },
          apns: { payload: { aps: { sound: 'default' } } },
        }),
  };
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ message }),
  });
  if (!res.ok) throw new Error(`FCM error [${platform}]: ${await res.text()}`);
  return res.json();
}

async function getAccessToken(serviceAccountJson) {
  const sa = JSON.parse(serviceAccountJson);
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: sa.client_email,
    // Only what this Worker uses: Firestore reads/writes and FCM sends.
    scope: [
      'https://www.googleapis.com/auth/datastore',
      'https://www.googleapis.com/auth/firebase.messaging',
    ].join(' '),
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };
  const privateKey = await importPrivateKey(sa.private_key);
  const jwt = await createJwt(payload, privateKey);
  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  const tokenData = await tokenResponse.json();
  if (!tokenData.access_token) throw new Error(`Token error: ${JSON.stringify(tokenData)}`);
  return tokenData.access_token;
}

async function importPrivateKey(pem) {
  const pemBody = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const binaryDer = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

async function createJwt(payload, privateKey) {
  const encodeB64url = (obj) =>
    btoa(JSON.stringify(obj)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  const header = { alg: 'RS256', typ: 'JWT' };
  const signingInput = `${encodeB64url(header)}.${encodeB64url(payload)}`;
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    privateKey,
    new TextEncoder().encode(signingInput),
  );
  const sigB64url = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
  return `${signingInput}.${sigB64url}`;
}
