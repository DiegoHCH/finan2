// finan2 site: language, theme, the cipher switch and the tour.
(function () {
  'use strict';

  var root = document.documentElement;
  var reduceMotion = matchMedia('(prefers-reduced-motion: reduce)').matches;

  // ── Language ──────────────────────────────────────────────────────
  // The page is written in Spanish; English replaces it in place.
  var EN = {
    skip: 'Skip to content',
    navLabel: 'Main',
    navTour: 'Inside',
    navVault: 'Privacy',
    navFaq: 'Questions',
    themeLabel: 'Change theme',
    eyebrow: 'Household money, for two',
    h1: 'Your household’s money, in view of <em>you&nbsp;both</em>.',
    lead: 'Finan2 brings what you spend, save and owe as a couple into one account. <strong>Each of you logs from your own phone and the other sees it right away</strong>, and amounts are encrypted before they leave it.',
    soon: 'Coming soon to',
    seeHow: 'See what it’s like ↓',
    slipTitle: 'Latest movements',
    slipNote: 'Hoyos home · October',
    mvSalary: 'Salary',
    mvCinema: 'Dinner and a movie',
    switchTitle: 'See what the server keeps',
    switchNote: 'Every figure on this page, as Firebase gets it.',
    tourEyebrow: 'What it’s like inside',
    tourTitle: 'Four tabs. No spreadsheet.',
    tourLead: 'Home, Movements, Plan and Settings, with “Log” always in the middle. This is a month at home.',
    p0: 'Home',
    t0: 'What’s left, without doing the math',
    d0: 'What’s left of this month’s plan, how much you can spend a day and who paid what: <span class="who-d">Diego</span> <span class="amt" data-v="1604000"></span>, <span class="who-v">Vale</span> <span class="amt" data-v="1018000"></span>.',
    a0: 'Finan2’s Home screen',
    p1: 'Log',
    t1: 'Logging an expense takes five seconds',
    d1: 'Amount, category and who paid. <strong>It works offline</strong>: it’s kept on the phone and sent on its own once the connection is back.',
    a1: 'Finan2’s Log screen',
    p2: 'Movements',
    t2: 'Everything that came in and went out, from both of you',
    d2: 'Search by description and filter by category, account, person or tag. Every movement says who paid it.',
    a2: 'Finan2’s Movements screen',
    pPlan: 'Plan',
    p3: 'Budget',
    t3: 'A plan for every category',
    d3: 'Decide how much goes to groceries, transport or going out, and see how much you’ve used. What’s left in a category can roll over to next month.',
    a3: 'Budget in Finan2',
    p4: 'Debts',
    t4: 'The month you’re debt-free',
    d4: 'With the Avalanche order, highest rate first, Finan2 tells you which one to pay and when you’re done. Card payments and loan installments, in one place.',
    a4: 'Debts in Finan2',
    p5: 'Goals',
    t5: 'Saving for something with a name',
    d5: 'The trip, the down payment, the emergency fund. What either of you puts in adds to the same goal, and Finan2 works out what’s needed each month.',
    a5: 'Savings goals in Finan2',
    p6: 'Notices',
    t6: 'Notices that arrive on time',
    d6: 'A payment coming up, a budget gone over or something your partner logged. Each of you picks which ones to get.',
    a6: 'Notices in Finan2',
    vaultEyebrow: 'Privacy',
    vaultTitle: 'You see <em><span class="amt" data-v="318000" data-keep></span></em>. The server sees noise.',
    vaultLead: 'Every amount is encrypted on the phone with a key only the two of you have. This is what is actually stored.',
    paneMine: 'On your phones',
    mineNote: '<b>The same on both phones,</b> right away: whoever logs it and whoever looks.',
    paneServer: 'On the server · transactions/Kq2…',
    docNote: '<b>What isn’t encrypted, we say:</b> descriptions and the names of categories and accounts are stored readable, protected so only the two of you can read them.',
    f1t: 'The key lives on your phones',
    f1d: 'It’s created with the household and goes from one phone to the other with the invite code. It’s never uploaded in the clear.',
    f2t: 'Twelve words in case you lose it',
    f2d: 'They’re shown once so you can write them on paper. Lose the key and the words, and nobody can read the amounts, us included.',
    f3t: 'One household, two people',
    f3d: 'Nobody else gets in. No ads, no link to your bank and no tools tracking you.',
    faqEyebrow: 'Questions',
    faqTitle: 'What people usually ask before starting',
    q1: 'How much does it cost?',
    a1q: 'Nothing. It has no ads and no paid plans.',
    q2: 'Can I log without internet?',
    a2q: 'Yes. What you log is kept on the phone, marked “not sent yet”, and goes up on its own when you’re back online, even if you close the app. If you both log offline, your balances don’t overwrite each other.',
    q3: 'What if I change phones?',
    a3q: 'Sign in with your email on the new one, and the other person passes the key with the household code, or you recover it with the twelve words.',
    q4: 'Does it connect to my bank?',
    a4q: 'No. You log what you spend; Finan2 never asks for passwords or card details.',
    q5: 'Can I take my data out?',
    a5q: 'Yes. From Settings you can export a report as CSV or PDF, and keep a backup of the household encrypted with your key.',
    q6: 'How do I delete my account?',
    a6q: 'In <b>Settings › Your account › Delete my account</b>. <a href="delete-account.html">What’s deleted and what isn’t</a>.',
    closeTitle: 'One place for the money you share.',
    closeLead: 'Coming soon to Android and iPhone, in English and Spanish.',
    footer: 'Finan2 · household money for two',
    privacy: 'Privacy policy',
    terms: 'Terms and conditions',
    deleteAccount: 'Delete your account',
    home: 'Home',
    delEyebrow: 'Your account',
    delTitle: 'Delete your account',
    delLead: 'You can delete your Finan2 account whenever you want, from the app. It’s immediate and can’t be undone.',
    delHowTitle: 'How to do it',
    delStep1: 'Open Finan2 and go to <span class="path">Settings › Your account</span>.',
    delStep2: 'Tap <strong>Delete my account</strong>.',
    delStep3: 'Confirm with your password or with Google, depending on how you sign in.',
    delWhatTitle: 'What’s deleted',
    delWhat1: 'Your user: email, name and photo.',
    delWhat2: 'Your notice preferences and your phones’ registration for notifications.',
    delWhat3: 'The household key stored on that phone.',
    delWhat4: '<strong>If you’re the only person in the household</strong>, everything in it as well: movements, accounts, budgets, debts, goals and the rest.',
    delKeepTitle: 'What stays',
    delKeep: 'If the other person stays in the household, its data stays with them: it belongs to both of you. What you logged is still there.',
    delHelpTitle: 'If you can’t get into the app',
    delHelp: 'Write to us at <a href="mailto:katanalabs.6002@gmail.com">katanalabs.6002@gmail.com</a> from your account’s email and we’ll delete it for you. If neither of you uses the household anymore, we can also delete all of its data.',
  };

  var spanish = {};
  var spanishAttrs = [];
  document.querySelectorAll('[data-i18n]').forEach(function (el) {
    spanish[el.dataset.i18n] = el.innerHTML;
  });
  document.querySelectorAll('[data-i18n-attr]').forEach(function (el) {
    var parts = el.dataset.i18nAttr.split(':');
    spanishAttrs.push([el, parts[0], parts[1], el.getAttribute(parts[0])]);
  });

  var lang = localStorage.getItem('finan2-lang') ||
    (/^es\b/i.test(navigator.language || 'es') ? 'es' : 'en');

  function applyLanguage() {
    root.lang = lang;
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var key = el.dataset.i18n;
      var html = lang === 'en' ? EN[key] : spanish[key];
      if (html != null && el.innerHTML !== html) el.innerHTML = html;
    });
    spanishAttrs.forEach(function (entry) {
      var value = lang === 'en' ? EN[entry[2]] : entry[3];
      if (value != null) entry[0].setAttribute(entry[1], value);
    });
    var button = document.getElementById('lang');
    if (button) {
      button.textContent = lang === 'en' ? 'ES' : 'EN';
      button.setAttribute('aria-label', lang === 'en' ? 'Español' : 'English');
    }
    renderAmounts(false);
  }

  // ── Amounts and what the server keeps of them ──────────────────────
  // Real ciphertext is base64url of a 12-byte nonce, the digits and a
  // 16-byte tag (HouseholdCrypto.encryptAmount): about 47 characters, new
  // each time. These are made up but shaped the same.
  var ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  function fakeCipher(seed, length) {
    var x = seed >>> 0 || 1;
    var out = '';
    for (var i = 0; i < length; i++) {
      x ^= x << 13; x ^= x >>> 17; x ^= x << 5; x >>>= 0;
      out += ALPHABET[x % 64];
    }
    return out;
  }

  var ciphered = false;
  function plainText(el) {
    var value = Number(el.dataset.v);
    var format = new Intl.NumberFormat(lang === 'en' ? 'en-US' : 'es-CO', { maximumFractionDigits: 0 });
    return (el.dataset.sign || '') + '$' + format.format(value);
  }
  function cipherText(el, index) {
    var full = fakeCipher(Number(el.dataset.v) * 31 + index * 7919, 47);
    return el.classList.contains('cipher-only') ? '"' + full + '"' : full.slice(0, 10) + '…' + full.slice(-4);
  }
  function wantsCipher(el) {
    if (el.classList.contains('cipher-only')) return true;
    if (el.hasAttribute('data-keep')) return false;
    return ciphered;
  }

  function renderAmounts(animate) {
    document.querySelectorAll('.amt[data-v]').forEach(function (el, index) {
      var target = wantsCipher(el) ? cipherText(el, index) : plainText(el);
      el.title = wantsCipher(el) && !el.classList.contains('cipher-only') ? cipherText(el, index).replace('…', '') : '';
      if (!animate || reduceMotion || el.classList.contains('cipher-only')) {
        el.textContent = target;
        return;
      }
      scramble(el, target, index);
    });
  }

  // Letters settle left to right, like a lock turning.
  function scramble(el, target, index) {
    var start = performance.now() + index * 18;
    var duration = 520;
    var from = el.textContent;
    function frame(now) {
      var t = Math.min(1, Math.max(0, (now - start) / duration));
      var settled = Math.floor(t * target.length);
      var length = Math.round(from.length + (target.length - from.length) * t);
      var noise = fakeCipher(Math.floor(now) + index, Math.max(0, length - settled));
      el.textContent = target.slice(0, settled) + noise;
      if (t < 1) requestAnimationFrame(frame);
      else el.textContent = target;
    }
    requestAnimationFrame(frame);
  }

  function setCiphered(on, animate) {
    ciphered = on;
    root.classList.toggle('ciphered', ciphered);
    document.querySelectorAll('[data-cipher-switch]').forEach(function (b) {
      b.setAttribute('aria-checked', String(ciphered));
    });
    renderAmounts(animate);
  }
  document.querySelectorAll('[data-cipher-switch]').forEach(function (button) {
    button.addEventListener('click', function () { setCiphered(!ciphered, true); });
  });

  // ── Theme ─────────────────────────────────────────────────────────
  function applyShots() {
    var suffix = root.dataset.theme === 'dark' ? 'oscuro' : 'claro';
    document.querySelectorAll('img[data-shot]').forEach(function (img) {
      img.src = 'assets/screens/' + img.dataset.shot + '-' + suffix + '.png';
    });
  }
  var themeButton = document.getElementById('theme');
  if (themeButton) {
    themeButton.addEventListener('click', function () {
      var next = root.dataset.theme === 'dark' ? 'light' : 'dark';
      root.dataset.theme = next;
      localStorage.setItem('finan2-theme', next);
      applyShots();
    });
  }
  matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function (e) {
    if (localStorage.getItem('finan2-theme')) return;
    root.dataset.theme = e.matches ? 'dark' : 'light';
    applyShots();
  });

  var langButton = document.getElementById('lang');
  if (langButton) {
    langButton.addEventListener('click', function () {
      lang = lang === 'en' ? 'es' : 'en';
      localStorage.setItem('finan2-lang', lang);
      applyLanguage();
    });
  }

  // ── Tour: the phone shows the place being read ────────────────────
  var steps = document.querySelectorAll('.step');
  var shots = document.querySelectorAll('.tour-phone img');
  if ('IntersectionObserver' in window && steps.length) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        var step = entry.target.dataset.step;
        steps.forEach(function (s) { s.classList.toggle('on', s.dataset.step === step); });
        shots.forEach(function (img) { img.classList.toggle('on', img.dataset.step === step); });
      });
    }, { rootMargin: '-45% 0px -45% 0px' });
    steps.forEach(function (s) { observer.observe(s); });
  }

  // ── Header rule once the page moves ───────────────────────────────
  var header = document.querySelector('.top');
  function onScroll() { if (header) header.classList.toggle('scrolled', scrollY > 8); }
  addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  applyShots();
  applyLanguage();

  // ?server opens the page already showing what the server keeps - a link
  // that makes the point by itself.
  if (new URLSearchParams(location.search).has('server')) setCiphered(true, false);
})();
