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

## Estado actual

- [x] Setup del proyecto, dependencias, theme y esqueleto de carpetas
- [ ] Auth + Hogar (login, crear/unirse a hogar)
- [ ] Transacciones
- [ ] Dashboard, presupuesto, deudas, ahorros
