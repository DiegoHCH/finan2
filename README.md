# Finan2

App Flutter de finanzas del hogar para dos personas: cada quien entra con su propia cuenta, pero ambos comparten un mismo "hogar" con transacciones, presupuesto, deudas y metas de ahorro.

## Stack

- **Flutter** (Material 3) + **Riverpod** (MVVM-ligero por feature)
- **Firebase Auth** + **Cloud Firestore** (offline-first, capa gratuita)
- **fl_chart** para gráficas, **intl** para formato de moneda/fecha

## Estructura

```
lib/
├── core/
│   ├── theme/           # Finan2Theme, paleta, tipografía (Plus Jakarta Sans)
│   ├── crypto/          # HouseholdCrypto - cifrado AES-GCM de montos
│   ├── widgets/         # Finan2* widgets compartidos
│   ├── notifications/   # Notificaciones locales (flutter_local_notifications)
│   └── utils/
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

## Correr el proyecto

```
flutter pub get
flutter run
```

## Firebase

Proyecto: `finan2` (región de Firestore: `southamerica-east1`). Configurado con `flutterfire configure`.

Proveedores **Email/Password** y **Google** habilitados en Authentication > Sign-in method.

## Estado actual

- [x] Setup del proyecto, dependencias, theme y esqueleto de carpetas
- [x] Firebase configurado (Auth + Firestore en `southamerica-east1`) y reglas de seguridad desplegadas
- [x] Auth (login/registro con email y Google) + Hogar (crear/unirse por código)
- [x] Ícono de la app generado a partir del mockup
- [x] Categorías, Cuentas, Transacciones (Movimientos), Transferencias
- [x] Dashboard, Presupuesto, Deudas (avalancha), Metas de ahorro, Reto de ahorro, Inversiones
- [x] Facturas recurrentes, Notas del mes, Resumen anual
- [x] Notificaciones (in-app + push real vía Cloudflare Worker) y preferencias
- [x] Exportar reporte (PDF/CSV)
- [x] Cifrado de montos en reposo (ver sección abajo)
- [x] CI (`flutter analyze` + `flutter test`), suite de tests unitarios/widget (94 tests, todos verdes)

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
  Console).
- **iOS**: no se va a publicar nativo en App Store - la app para iOS es la SPA/PWA descrita
  abajo. El borrador de ficha de App Store Connect que se había preparado quedó guardado sin
  usar en `store/app_store_metadata.md.on-hold` por si esto cambia.
- **Política de privacidad**: `store/privacy_policy.md` (fuente), publicada en
  https://claude.ai/code/artifact/07ca9609-ec69-4b85-be4b-f8ccc5e5f9c0 - **ese link empieza
  privado**, hay que compartirlo desde el menú de la página antes de pegarlo en Play Console
  (o donde termine viviendo la SPA de iOS), o migrar el contenido a una URL propia.

## SPA/PWA para iOS

Decisión (2026-07-12): en vez de publicar nativo en App Store, iOS usa el target web de
Flutter (`web/`) como PWA. Investigación completa y diseño en el historial de esta
conversación; resumen de lo construido:

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

**Validado:** `flutter analyze`/`flutter test` en verde, `flutter build web` compila,
`firestore.rules` desplegable (`firebase deploy --only firestore:rules --dry-run`). El Worker
tiene un modo `DRY_RUN` (env var, nunca un secreto real desplegado) que lee Firestore real sin
llamar a FCM ni escribir `sentReminders` - se probó localmente con
`wrangler dev --test-scheduled` contra el proyecto real: encontró el hogar existente, calculó
bien la hora de Colombia, y no disparó nada porque ninguna condición coincidía en ese momento
(no se validó en vivo el camino positivo "sí envía", solo que lee/decide correctamente).

**Desplegado (2026-07-12):** `wrangler deploy` ya corrió - el Cron Trigger
(`0 * * * *`, cada hora) está activo en producción en
`https://finan2-notifications.katanalabs-6002.workers.dev`.

## Pendientes

- [ ] Probar login con Google, instalación y push reales en un iPhone/Safari - el botón
  embebido compila (`flutter build web`) pero nunca se ha hecho clic en uno de verdad
- [ ] Capturas de pantalla para las fichas de tienda - necesitan la app corriendo con datos
  reales en un dispositivo/simulador; no se generaron en esta pasada (fue una decisión
  explícita para no meterle datos ficticios a las capturas)
- [ ] QA manual en dispositivo/emulador de los flujos completos (login → hogar → cada feature) — hasta ahora solo hay cobertura de tests unitarios/widget
- [ ] Datos de prueba existentes en Firestore (si los hay) tienen montos en texto plano — no compatibles con el nuevo formato cifrado, hay que borrarlos antes de volver a usar la app en el proyecto real
