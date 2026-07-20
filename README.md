# Finan2

App Flutter de finanzas del hogar para dos personas: cada quien entra con su propia cuenta, pero ambos comparten un mismo "hogar" con transacciones, presupuesto, deudas y metas de ahorro.

## Stack

- **Flutter** 3.44.6 (Material 3) + **Riverpod** (MVVM-ligero por feature)
- **Firebase Auth** + **Cloud Firestore** + **Cloud Messaging** (offline-first, capa gratuita)
- **Cloudflare Workers** para push server-side y recordatorios programados (`cloudflare/finan2-notifications/`)
- **fl_chart** para gráficas, **intl** para formato de moneda/fecha
- Fuente de marca: **Plus Jakarta Sans** (empaquetada localmente, sin `google_fonts`)

## Estructura

```
lib/
├── core/
│   ├── theme/           # Finan2Theme, paleta, tipografía
│   ├── crypto/          # HouseholdCrypto - cifrado AES-GCM de montos
│   ├── widgets/         # Finan2* widgets compartidos (bottom sheets, splash, etc.)
│   ├── notifications/   # Notificaciones locales (flutter_local_notifications)
│   └── utils/           # incl. error_messages.dart (mapeo de errores a mensajes en español)
└── features/
    ├── auth/
    ├── household/
    ├── accounts/
    ├── categories/
    ├── transactions/
    ├── dashboard/
    ├── budget/
    ├── debts/
    ├── savings_goals/
    ├── savings_challenge/
    ├── investments/
    ├── recurring_bills/
    ├── transfers/
    ├── monthly_notes/
    ├── annual_summary/
    ├── notifications/
    ├── notification_prefs/
    ├── export/
    └── settings/
```

Cada feature se organiza como `data/` (modelos + repositorios Firestore) y `presentation/` (`viewmodels/` + `screens/`).

Otras carpetas relevantes en la raíz del repo:

```
docs/              # sitio público (GitHub Pages) - ver sección abajo
design-archive/    # mockups/exploraciones de diseño archivados, NO servidos por Pages
cloudflare/        # Worker de notificaciones push + recordatorios programados
store/             # metadata de tienda (política de privacidad, ficha de App Store en pausa)
```

## Correr el proyecto

```
flutter pub get
flutter run
```

Para builds que usan Firebase Cloud Messaging (push), incluir los dart-defines:

```
flutter run --dart-define-from-file=.secrets/dart-defines.json
```

## Firebase

Proyecto: `finan2` (región de Firestore: `southamerica-east1`). Configurado con `flutterfire configure`.

Proveedores **Email/Password** y **Google** habilitados en Authentication > Sign-in method.

## Estado actual

- [x] Setup del proyecto, dependencias, theme y esqueleto de carpetas
- [x] Firebase configurado (Auth + Firestore en `southamerica-east1`) y reglas de seguridad desplegadas
- [x] Auth (login/registro con email y Google, recuperar contraseña) + Hogar (crear/unirse por código)
- [x] Ícono de la app (adaptativo/squircle) + ícono monocromático para notificaciones Android
- [x] Splash screen nativo (Android/iOS, claro y de marca) con handoff a una versión animada en Flutter (puntos de carga) mientras resuelve sesión/hogar
- [x] Categorías, Cuentas, Transacciones (Movimientos), Transferencias
- [x] Dashboard, Presupuesto, Deudas (avalancha), Metas de ahorro, Reto de ahorro, Inversiones
- [x] Facturas recurrentes, Notas del mes, Resumen anual
- [x] Notificaciones (in-app + push real vía Cloudflare Worker) y preferencias
- [x] Exportar reporte (PDF/CSV)
- [x] Cifrado de montos en reposo (ver sección abajo)
- [x] Todas las modales de la app son bottom sheets (nunca `AlertDialog` centrado) - helpers
  compartidos en `lib/core/widgets/finan2_bottom_sheet.dart`
  (`showFinan2ConfirmSheet`/`showFinan2InputSheet`/`showFinan2ErrorSheet`/`showFinan2InfoSheet`)
- [x] Errores mostrados al usuario siempre en español y sin exponer el mensaje crudo de la
  excepción - mapeo único en `lib/core/utils/error_messages.dart`
- [x] Sitio público en `docs/` listo para GitHub Pages (landing, política de privacidad, términos y condiciones)
- [x] CI (`flutter analyze` + `flutter test`), suite de tests unitarios/widget (142 tests, todos verdes)

## Cifrado de montos

Todos los campos monetarios (`amount`, `balance`, `targetAmount`, etc. — no nombres ni
descripciones) se cifran con AES-256-GCM (`lib/core/crypto/household_crypto.dart`) antes de
escribirse a Firestore. La llave se genera en el dispositivo al crear un hogar y **nunca se
sube a Firestore**: viaja pegada al código de invitación (`CODIGO.llave`, ver
`InviteHouseholdScreen`) y se guarda localmente con `flutter_secure_storage`
(Keychain/Keystore). Así, ni con acceso admin al proyecto de Firebase/GCP se pueden leer los
montos reales de un hogar — solo los 2 dispositivos que tienen el código completo pueden
descifrarlos.

**Importante:** si ambos dispositivos pierden la llave (ej. reinstalar sin haber guardado el
código completo en otro lado), los montos de ese hogar quedan indescifrables para siempre —
no hay forma de recuperarlos del lado del servidor. El botón "Copiar código" en Ajustes
re-comparte la llave ya existente de este dispositivo (nunca genera una nueva, eso rompería
los datos ya cifrados).

Nombres, descripciones y notas de texto **no** están cifrados en esta versión (v1) — quedan
legibles en la consola de Firestore. Cifrarlos también es posible pero requiere resolver el
`orderBy('name')` de deudas/inversiones (dejaría de funcionar sobre texto cifrado) y hacer
genéricas las notificaciones que hoy muestran el nombre de la entidad.

## Firma de release (Android)

`android/app/build.gradle.kts` firma el build type `release` con
`.secrets/finan2-release.jks` (alias `finan2`, passwords en
`.secrets/android-key.properties`) cuando ese archivo existe en la máquina, y cae a la
firma de debug si no — así un clone nuevo o CI no se rompen por no tener el secreto.
Verificado con `flutter build apk --release` + `apksigner verify --print-certs`.

**Importante — respaldar el keystore ahora:** `.secrets/finan2-release.jks` y
`.secrets/android-key.properties` están en `.gitignore` (nunca se suben) y solo existen en
esta máquina. Si se pierden, no se puede volver a firmar una actualización de la app con la
misma identidad en Play Store. Cópialos a un gestor de contraseñas o backup seguro antes de
publicar la primera versión — no dependas de que este equipo no falle.

## Metadata de tienda

- **Versión**: `1.0.0+1` (`pubspec.yaml`).
- **Play Store**: `android/fastlane/metadata/android/es-419/` (título, descripción corta y
  larga - formato fastlane estándar, listo para `fastlane deploy` o carga manual en Play
  Console). Aún no publicada — el badge de Google Play en `docs/index.html` está deshabilitado
  a propósito hasta que exista una ficha real.
- **iOS**: decisión revertida (2026-07-20) — sí se va a publicar una app nativa en App Store
  (se va a comprar la licencia de desarrollador Apple), en vez de depender solo de la PWA
  descrita más abajo. El borrador de ficha de App Store Connect que se había dejado en pausa
  está listo para retomar en `store/app_store_metadata.md.on-hold` (quitarle el sufijo
  `.on-hold` cuando se vaya a usar). El badge de App Store en `docs/index.html` también está
  deshabilitado hasta que exista la ficha.
- **Política de privacidad / Términos y condiciones**: fuente en `store/privacy_policy.md` y
  publicadas como páginas propias en `docs/privacy.html` y `docs/terms.html` (ver sección
  "Sitio público" abajo) - dejan de depender de un link de artifact de claude.ai.

## Sitio público (GitHub Pages)

`docs/` contiene el sitio que se sirve con GitHub Pages (Settings → Pages → Deploy from a
branch → `main` → `/docs`):

- `docs/index.html` — landing. Sin ningún CTA hacia la web app (`finan2.web.app`): la
  distribución es por las tiendas, así que solo muestra los badges de Google Play / App Store
  (deshabilitados hasta que existan las fichas reales).
- `docs/privacy.html` — política de privacidad.
- `docs/terms.html` — términos y condiciones.
- `docs/assets/` — badges oficiales de las tiendas.

Los 3 documentos son HTML autocontenidos (ícono real de la app y Plus Jakarta Sans embebidos
como base64, sin dependencias externas) y se enlazan entre sí con rutas relativas. Una vez
publicado el repo queda en:

```
https://diegohch.github.io/finan2/
https://diegohch.github.io/finan2/privacy.html
https://diegohch.github.io/finan2/terms.html
```

`design-archive/` guarda copias HTML de mockups/exploraciones de diseño (pantallas completas
de la app, exploración de nombre/logo) **fuera** de `docs/` a propósito, para que no queden
públicas por Pages — es solo respaldo interno.

## SPA/PWA para iOS

Construida el 2026-07-12 como plan de distribución para iOS (ver detalle técnico abajo). Con
la decisión de comprar la licencia de Apple Developer y publicar nativo (2026-07-20), esta PWA
deja de ser el canal principal para iOS, pero el código sigue funcionando y puede quedar como
respaldo (acceso vía navegador sin pasar por la tienda) o retirarse más adelante — no se ha
tocado nada de esto todavía.

- **Base web**: `web/manifest.json`/`index.html` con metadata real (nombre, descripción,
  meta tags de iOS). Todo lo demás (Firestore, Firebase Auth, `cryptography`) funciona igual
  sin cambios.
- **Login con Google en web**: `GoogleSignIn.authenticate()` (lo que usa
  `auth_repository.dart` en móvil) lanza `UnimplementedError` en el plugin web - GIS exige que
  el usuario interactúe con su propio botón renderizado, no un popup disparado desde código.
  En web se usa `GoogleSignInWebButton`
  (`lib/features/auth/presentation/widgets/google_sign_in_web_button*.dart`, patrón
  condicional igual al de `core/pwa/`) que envuelve `renderButton()` de
  `google_sign_in_web/web_only.dart`, y `AuthRepository.googleWebSignInEvents` escucha el
  stream de eventos de autenticación para completar el login contra Firebase - `AuthGate` ya
  reacciona solo una vez que eso sucede. El client ID web usado es el "Web client"
  auto-creado por Google (mismo que ya usa Android internamente, sacado de
  `google-services.json`).
- **Instalación + riesgo de la llave**: banner en `Finan2HomeShell` que explica cómo instalar
  en iOS ("Compartir → Agregar a inicio", no hay prompt automático), y
  `lib/core/pwa/storage_persistence.dart` pide la Persistent Storage API del navegador al
  entrar (con permiso de notificaciones primero, que Safari respeta más). Si el navegador no
  la concede, Ajustes muestra un aviso recomendando guardar el código completo del hogar en
  otro lado - iOS puede borrar el storage local (y con él, la llave de cifrado) si la PWA no
  se abre en ~7 días.
- **Push en web**: `web/firebase-messaging-sw.js` nuevo, y `push_service.dart` ya pasa una
  VAPID key en `getToken()` y guarda `platform: 'web'` (el lado del Worker ya lo esperaba).
  La VAPID key real ya está generada y en `.secrets/dart-defines.json` bajo
  `FINAN2_FCM_VAPID_KEY` - recuerda compilar/correr con
  `--dart-define-from-file=.secrets/dart-defines.json` para que se incluya.
- **Recordatorios programados en servidor**: `flutter_local_notifications` no tiene
  scheduling real en background en web, así que se movieron al Cron Trigger nuevo en
  `cloudflare/finan2-notifications/worker.js` (`wrangler.toml` ya tiene `[triggers] crons =
  ["0 * * * *"]`). Para que el cron pueda decidir sin la llave de cifrado del hogar, cada
  deuda ahora guarda también un campo plano `hasBalance` (junto al `balance` cifrado), y las
  preferencias de recordatorio relevantes (`dailyReminder`, `weeklySummary`, `debtPayments`)
  se sincronizan a `households/{hid}/memberPrefs/{uid}` cuando el usuario las cambia en
  Ajustes (antes eran solo locales). Reglas de Firestore actualizadas para permitir ese
  nuevo subcollection.

**Desplegado:** `wrangler deploy` ya corrió - el Cron Trigger (`0 * * * *`, cada hora) está
activo en producción en `https://finan2-notifications.katanalabs-6002.workers.dev`.

## Pendientes

- [ ] Comprar la licencia de Apple Developer y publicar la app nativa en App Store (retomar
  `store/app_store_metadata.md.on-hold`)
- [ ] Publicar la ficha en Play Store y habilitar el badge correspondiente en `docs/index.html`
- [ ] Habilitar GitHub Pages en la configuración del repo (`Settings → Pages`, servir desde
  `main`/`docs`)
- [ ] Capturas de pantalla para las fichas de tienda - necesitan la app corriendo con datos
  reales en un dispositivo/simulador; no se han generado todavía (decisión explícita de no
  meterle datos ficticios a las capturas)
- [ ] Probar login con Google, instalación y push reales de la PWA en un iPhone/Safari - el
  botón embebido compila (`flutter build web`) pero nunca se ha probado en un dispositivo real
- [ ] QA manual en dispositivo/emulador de los flujos completos (login → hogar → cada feature)
  — hasta ahora solo hay cobertura de tests unitarios/widget
