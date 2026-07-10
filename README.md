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
│   └── theme/          # Finan2Theme, paleta, tipografía (Plus Jakarta Sans)
└── features/
    ├── auth/
    ├── household/
    ├── accounts/
    ├── categories/
    ├── transactions/
    ├── dashboard/
    ├── budget/
    ├── debts/
    ├── savings/
    ├── investments/
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

**Pendiente manual:** habilitar los proveedores **Email/Password** y **Google** en
[Authentication > Sign-in method](https://console.firebase.google.com/project/finan2/authentication/providers) —
sin esto el login/registro no funciona en tiempo real (el código ya está listo y compila).

## Estado actual

- [x] Setup del proyecto, dependencias, theme y esqueleto de carpetas
- [x] Firebase configurado (Auth + Firestore en `southamerica-east1`) y reglas de seguridad desplegadas
- [x] Auth (login/registro con email y Google) + Hogar (crear/unirse por código, pantalla temporal de inicio)
- [ ] Habilitar proveedores de Auth en la consola (paso manual, ver arriba)
- [ ] Transacciones
- [ ] Dashboard, presupuesto, deudas, ahorros
