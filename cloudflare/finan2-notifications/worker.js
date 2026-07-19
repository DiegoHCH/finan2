// Relays a single push notification to every device of a Finan2 household,
// except the device(s) belonging to whoever triggered it (they already see
// the change live in the app). Stateless: reads tokens from Firestore on
// every call, no KV/D1 involved.
//
// Auth model: a shared secret sent in the request body (WORKER_SECRET). The
// actual push send is authenticated as a Google service account, whose
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

export default {
  async fetch(request, env) {
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return new Response('Invalid JSON', { status: 400 });
    }

    const { householdId, title, body: notifBody, secret, excludeUid } = body;
    if (!secret || secret !== env.WORKER_SECRET) {
      return new Response('Unauthorized', { status: 401 });
    }
    if (!householdId || !title || !notifBody) {
      return new Response('Missing householdId, title or body', { status: 400 });
    }

    try {
      const accessToken = await getAccessToken(env.FIREBASE_SERVICE_ACCOUNT);
      const projectId = env.FIREBASE_PROJECT_ID;

      const allTokens = await getHouseholdTokens(accessToken, projectId, householdId);
      const tokens = excludeUid ? allTokens.filter((t) => t.uid !== excludeUid) : allTokens;

      const results = await Promise.allSettled(
        tokens.map(({ token, platform }) =>
          sendToToken({ title, body: notifBody, accessToken, projectId, token, platform }),
        ),
      );

      return Response.json({
        tokensSent: tokens.length,
        errors: results.filter((r) => r.status === 'rejected').length,
      });
    } catch (e) {
      return Response.json({ error: e.message }, { status: 500 });
    }
  },

  async scheduled(event, env, ctx) {
    ctx.waitUntil(handleScheduled(env));
  },
};

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

    let debts = null; // fetched lazily, at most once per household per run

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

async function getMemberPrefs(accessToken, projectId, householdId, uid) {
  const defaults = {
    dailyReminder: true,
    dailyReminderHour: 20,
    weeklySummary: true,
    debtPayments: true,
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
  };
}

async function getHouseholdDebts(accessToken, projectId, householdId) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/households/${householdId}/debts?pageSize=1000`,
    { headers: { Authorization: `Bearer ${accessToken}` } },
  );
  const data = await res.json();
  if (!data.documents) return [];
  return data.documents.map((doc) => ({
    id: doc.name.split('/').pop(),
    name: doc.fields?.name?.stringValue ?? '',
    paymentDay: doc.fields?.paymentDay?.integerValue
      ? parseInt(doc.fields.paymentDay.integerValue, 10)
      : 1,
    hasBalance: doc.fields?.hasBalance?.booleanValue ?? false,
  }));
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
          android: { notification: { channel_id: 'finan2_activity', sound: 'default' } },
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
    scope: 'https://www.googleapis.com/auth/cloud-platform',
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
