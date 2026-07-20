# Finan2

App de finanzas del hogar para dos personas: cada quien entra con su propia cuenta, pero
ambos comparten un mismo "hogar" con transacciones, presupuesto, deudas, metas de ahorro,
inversiones y facturas recurrentes. Los montos se cifran en el dispositivo antes de guardarse.

## Funcionalidades

- Cuentas, categorías, transacciones y transferencias entre cuentas
- Presupuesto mensual por categoría y resumen anual
- Deudas con método de pago avalancha, metas de ahorro y reto de ahorro
- Inversiones y facturas recurrentes
- Notas del mes, exportar reporte (PDF/CSV)
- Notificaciones in-app y push (recordatorios diarios/semanales, pagos de deuda, actividad de la pareja)
- Hogar compartido entre 2 personas: se une por código de invitación

## Stack

- **Flutter** (Material 3) + **Riverpod** para estado (MVVM ligero por feature)
- **Firebase**: Auth (email/password + Google), Cloud Firestore, Cloud Messaging
- **Cloudflare Workers** para el envío de push server-side y recordatorios programados por cron
- **fl_chart** para gráficas, **intl** para formato de moneda/fecha
- Tipografía de marca: Plus Jakarta Sans (empaquetada localmente)

## Arquitectura

```
lib/
├── core/
│   ├── theme/           # Finan2Theme, paleta, tipografía
│   ├── crypto/          # HouseholdCrypto - cifrado AES-GCM de montos
│   ├── widgets/         # Finan2* widgets compartidos (bottom sheets, splash, etc.)
│   ├── notifications/   # Notificaciones locales (flutter_local_notifications)
│   ├── pwa/              # Soporte de instalación/persistencia para el target web
│   └── utils/            # incl. error_messages.dart (errores -> mensajes en español)
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

Cada feature se organiza como `data/` (modelos + repositorios Firestore) y `presentation/`
(`viewmodels/` + `screens/`). Todas las modales de la app son bottom sheets, nunca `AlertDialog`
centrado (`lib/core/widgets/finan2_bottom_sheet.dart`).

Otras carpetas en la raíz del repo:

```
docs/              # sitio público (GitHub Pages): landing, política de privacidad, términos
design-archive/    # mockups/exploraciones de diseño archivados (no públicos)
cloudflare/        # Worker de notificaciones push + recordatorios programados
store/             # metadata de tienda (política de privacidad, ficha de App Store)
android/fastlane/  # metadata de Play Store
```

## Seguridad: cifrado de montos

Los campos monetarios (`amount`, `balance`, `targetAmount`, etc. — no nombres ni
descripciones) se cifran con AES-256-GCM (`lib/core/crypto/household_crypto.dart`) antes de
escribirse a Firestore. La llave se genera en el dispositivo al crear un hogar y nunca se sube
a Firestore: viaja pegada al código de invitación (`CODIGO.llave`) y se guarda localmente con
`flutter_secure_storage` (Keychain/Keystore). Ni con acceso admin al proyecto de
Firebase/GCP se pueden leer los montos reales de un hogar — solo los 2 dispositivos que tienen
el código completo pueden descifrarlos.

Nombres, descripciones y notas de texto no están cifrados en esta versión.

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

Proyecto: `finan2` (región de Firestore: `southamerica-east1`), configurado con
`flutterfire configure`. Proveedores **Email/Password** y **Google** habilitados en
Authentication.

## Tests

```
flutter analyze
flutter test
```
