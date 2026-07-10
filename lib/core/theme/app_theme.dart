// ============================================================================
// Finan2 · Design tokens para Flutter
// ----------------------------------------------------------------------------
// Traducción directa del mockup de diseño a un ThemeData usable.
// Uso:
//   MaterialApp(
//     theme: Finan2Theme.light,
//     darkTheme: Finan2Theme.dark,
//     themeMode: ThemeMode.system,
//   )
//
// Colores semánticos y de usuario via extension:
//   final c = Theme.of(context).extension<Finan2Colors>()!;
//   Text('...', style: TextStyle(color: c.income));
//
// Iconografía: SOLO Material Design (clase Icons, incluida en Flutter, gratis).
//   Icon(Finan2Icons.deudas)  ·  Icon(Finan2Icons.categoria('mercado'))
// ============================================================================

import 'package:flutter/material.dart';
// Tipografía: Plus Jakarta Sans (moderna, geométrica). Gratis, OFL.
// Empaquetada localmente en assets/fonts/ y declarada en pubspec.yaml
// (sin dependencia de google_fonts ni descarga en runtime).

// ─────────────────────────────────────────────────────────────────────────
// PALETA
// ─────────────────────────────────────────────────────────────────────────

/// Fuente única de verdad de los colores de marca.
abstract class Finan2Palette {
  // Marca
  static const brand = Color(0xFF0F9D74); // esmeralda
  static const brandDeep = Color(0xFF0A5C47);
  static const brandTintLight = Color(0xFFE3F4EE);
  static const brandTintDark = Color(0xFF123028);
  static const brandDarkMode = Color(0xFF2DD39C);
  static const brandDeepDark = Color(0xFF1D8B68);

  // Acento
  static const gold = Color(0xFFC8892F); // ahorros / metas
  static const goldDark = Color(0xFFE0AD5E);

  // Semántica
  static const positive = Color(0xFF0F9D74); // ingreso
  static const negative = Color(0xFFD4453F); // gasto / deuda
  static const positiveDark = Color(0xFF2DD39C);
  static const negativeDark = Color(0xFFF2726C);

  // Colores de usuario (dos miembros del hogar)
  static const userA = Color(0xFF0F9D74);
  static const userB = Color(0xFF7C5CE0);
  static const userADark = Color(0xFF2DD39C);
  static const userBDark = Color(0xFFA48BFF);

  // Neutros — LIGHT (sesgo verde-frío, elegidos)
  static const groundLight = Color(0xFFEEF2F0);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surface2Light = Color(0xFFF4F7F5);
  static const inkLight = Color(0xFF0D1F1A);
  static const inkSoftLight = Color(0xFF4A5C55);
  static const inkFaintLight = Color(0xFF869590);
  static const lineLight = Color(0xFFDFE6E2);

  // Neutros — DARK (verde-negro profundo)
  static const groundDark = Color(0xFF0A1210);
  static const surfaceDark = Color(0xFF12201B);
  static const surface2Dark = Color(0xFF17281F);
  static const inkDark = Color(0xFFE9F1EC);
  static const inkSoftDark = Color(0xFFA3B4AD);
  static const inkFaintDark = Color(0xFF6B7D76);
  static const lineDark = Color(0xFF22342C);
}

// ─────────────────────────────────────────────────────────────────────────
// TIPOGRAFÍA — escala de tipos (tamaños, pesos, tracking)
// ─────────────────────────────────────────────────────────────────────────

/// Escala tipográfica del mockup, mapeada al sistema de Material 3.
/// Fuente: stack del sistema (la app puede cambiar a 'Inter' si se incluye).
///
/// | Rol                        | px  | peso | tracking |
/// |----------------------------|-----|------|----------|
/// | Cifra hero (patrimonio)    | 30  | 750  | -0.5     |
/// | Título de pantalla / H2    | 22  | 720  | -0.4     |
/// | Título de card / H3        | 18  | 700  | -0.2     |
/// | Subtítulo / app-top        | 15  | 650  |  0       |
/// | Cuerpo                     | 14  | 400  |  0       |
/// | Cuerpo secundario (soft)   | 13  | 400  |  0       |
/// | Micro (faint)              | 11.5| 500  |  0       |
/// | Botón                      | 14  | 700  |  0.1     |
/// | Chip                       | 12  | 600  |  0.1     |
/// | Label (MAYÚS)              | 10.5| 700  |  0.8     |
abstract class Finan2Type {
  static const _feat = [FontFeature.tabularFigures()];

  static TextTheme textTheme({required Color ink, required Color soft}) {
    return TextTheme(
      // Cifras grandes de dinero (balance, meta, saldo)
      displayMedium: TextStyle(
        fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.5,
        height: 1.05, color: ink, fontFeatures: _feat,
      ),
      displaySmall: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4,
        color: ink, fontFeatures: _feat,
      ),
      // Título de pantalla / sección
      headlineSmall: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4,
        color: ink,
      ),
      // Título de card
      titleLarge: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2,
        color: ink,
      ),
      // Subtítulo / encabezado de app
      titleMedium: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w600, color: ink,
      ),
      titleSmall: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: ink,
      ),
      // Cuerpo
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ink),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: soft, height: 1.45),
      bodySmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: soft),
      // Botón
      labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1, color: ink,
      ),
      // Chip
      labelMedium: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: soft,
      ),
      // Label en MAYÚSCULAS (eyebrows, encabezados de campo)
      labelSmall: TextStyle(
        fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8,
        color: soft,
      ),
    );
  }

  /// Nombre de familia declarado en pubspec.yaml (fuente local).
  static const fontFamily = 'Plus Jakarta Sans';

  /// Cifra de dinero con figuras tabulares (columnas alineadas).
  static const money = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

// ─────────────────────────────────────────────────────────────────────────
// TAMAÑOS · ESPACIADO · RADIOS
// ─────────────────────────────────────────────────────────────────────────

/// Escala de espaciado (múltiplos de ~4).
abstract class Finan2Space {
  static const xxs = 4.0;
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Radios de esquina.
abstract class Finan2Radius {
  static const chip = 999.0; // pill
  static const field = 12.0;
  static const card = 16.0;
  static const sheet = 34.0;
}

/// Tamaños de iconos y elementos.
abstract class Finan2Sizes {
  static const iconXs = 16.0;
  static const iconSm = 18.0; // dentro de chips / filas
  static const iconMd = 22.0; // nav / acciones
  static const iconLg = 28.0;
  static const iconXl = 36.0; // estados vacíos

  static const avatar = 30.0;
  static const avatarLg = 62.0;
  static const navBarHeight = 64.0;
  static const fab = 50.0;
}

// ─────────────────────────────────────────────────────────────────────────
// ICONOGRAFÍA — SOLO Material Design (clase Icons, sin paquetes extra)
// ─────────────────────────────────────────────────────────────────────────

/// Todos los iconos de la app son Material (variante *_outlined).
/// La clase `Icons` viene incluida en Flutter: gratis y sin dependencias.
/// (Si algún día quieres el set completo de Material Symbols, agrega el
///  paquete `material_symbols_icons` — opcional, no necesario para esto.)
abstract class Finan2Icons {
  // Navegación inferior
  static const inicio = Icons.home_outlined;
  static const movimientos = Icons.receipt_long_outlined;
  static const deudas = Icons.credit_card_outlined;
  static const metas = Icons.savings_outlined;
  static const ajustes = Icons.settings_outlined;

  // Acciones
  static const agregar = Icons.add;
  static const editar = Icons.edit_outlined;
  static const eliminar = Icons.delete_outline;
  static const compartir = Icons.ios_share;
  static const exportar = Icons.picture_as_pdf_outlined;
  static const notificacion = Icons.notifications_outlined;
  static const alerta = Icons.warning_amber_rounded;
  static const chevron = Icons.chevron_right;
  static const check = Icons.check_rounded;
  static const google = Icons.g_mobiledata; // placeholder; logo real via asset

  // Config / ajustes
  static const moneda = Icons.paid_outlined;
  static const anio = Icons.calendar_today_outlined;
  static const semana = Icons.event_outlined;
  static const categorias = Icons.sell_outlined;
  static const miembros = Icons.group_outlined;
  static const video = Icons.videocam_outlined;
  static const codigo = Icons.vpn_key_outlined;
  static const hogar = Icons.home_work_outlined;
  static const resumen = Icons.bar_chart_rounded;

  // Cuentas / billeteras
  static const cuentas = Icons.account_balance_wallet_outlined;
  static const efectivo = Icons.payments_outlined;
  static const banco = Icons.account_balance_outlined;
  static const billeteraDigital = Icons.smartphone_outlined;
  static const tarjetaDebito = Icons.credit_card_outlined;

  /// Icono por tipo de categoría / concepto financiero.
  /// La clave es un slug estable que guardas en Firestore junto a la categoría.
  static const _categoria = <String, IconData>{
    // Ingresos
    'salario': Icons.work_outline,
    'freelance': Icons.payments_outlined,
    // Gastos / facturas
    'mercado': Icons.shopping_cart_outlined,
    'arriendo': Icons.home_outlined,
    'transporte': Icons.local_gas_station_outlined,
    'vehiculo': Icons.directions_car_outlined,
    'ocio': Icons.movie_outlined,
    'servicios': Icons.bolt_outlined,
    'celular': Icons.smartphone_outlined,
    'streaming': Icons.live_tv_outlined,
    'restaurante': Icons.restaurant_outlined,
    'salud': Icons.medical_services_outlined,
    'educacion': Icons.school_outlined,
    'regalo': Icons.card_giftcard_outlined,
    'hogar_aseo': Icons.cleaning_services_outlined,
    // Deudas
    'tarjeta': Icons.credit_card_outlined,
    'credito': Icons.account_balance_outlined,
    'hipoteca': Icons.home_outlined,
    // Ahorros / metas
    'viaje': Icons.flight_outlined,
    'emergencia': Icons.health_and_safety_outlined,
    'meta': Icons.track_changes_outlined,
    'casa': Icons.house_outlined,
    // Inversiones
    'renta_fija': Icons.account_balance_outlined,
    'acciones': Icons.trending_up_rounded,
    'cripto': Icons.currency_bitcoin_rounded,
  };

  /// Devuelve el icono de una categoría por su slug (fallback: etiqueta).
  static IconData categoria(String slug) =>
      _categoria[slug] ?? Icons.label_outline;
}

// ─────────────────────────────────────────────────────────────────────────
// TOKENS EXTRA (semántica que Material no cubre)
// ─────────────────────────────────────────────────────────────────────────

@immutable
class Finan2Colors extends ThemeExtension<Finan2Colors> {
  final Color income; // ingreso (verde)
  final Color expense; // gasto / deuda (rojo)
  final Color saving; // ahorro / meta (ámbar)
  final Color savingTint;
  final Color brandTint;
  final Color brandDeep; // fin de degradado de marca, reactivo al tema
  final Color userA;
  final Color userB;
  final Color ink; // texto principal
  final Color inkSoft; // texto secundario
  final Color inkFaint; // texto terciario / labels
  final Color line; // bordes / divisores
  final Color surfaceAlt; // superficie secundaria (surface-2)

  const Finan2Colors({
    required this.income,
    required this.expense,
    required this.saving,
    required this.savingTint,
    required this.brandTint,
    required this.brandDeep,
    required this.userA,
    required this.userB,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.line,
    required this.surfaceAlt,
  });

  static const light = Finan2Colors(
    income: Finan2Palette.positive,
    expense: Finan2Palette.negative,
    saving: Finan2Palette.gold,
    savingTint: Color(0xFFF8EEDE),
    brandTint: Finan2Palette.brandTintLight,
    brandDeep: Finan2Palette.brandDeep,
    userA: Finan2Palette.userA,
    userB: Finan2Palette.userB,
    ink: Finan2Palette.inkLight,
    inkSoft: Finan2Palette.inkSoftLight,
    inkFaint: Finan2Palette.inkFaintLight,
    line: Finan2Palette.lineLight,
    surfaceAlt: Finan2Palette.surface2Light,
  );

  static const dark = Finan2Colors(
    income: Finan2Palette.positiveDark,
    expense: Finan2Palette.negativeDark,
    saving: Finan2Palette.goldDark,
    savingTint: Color(0xFF2C2415),
    brandTint: Finan2Palette.brandTintDark,
    brandDeep: Finan2Palette.brandDeepDark,
    userA: Finan2Palette.userADark,
    userB: Finan2Palette.userBDark,
    ink: Finan2Palette.inkDark,
    inkSoft: Finan2Palette.inkSoftDark,
    inkFaint: Finan2Palette.inkFaintDark,
    line: Finan2Palette.lineDark,
    surfaceAlt: Finan2Palette.surface2Dark,
  );

  @override
  Finan2Colors copyWith({
    Color? income, Color? expense, Color? saving, Color? savingTint,
    Color? brandTint, Color? brandDeep, Color? userA, Color? userB, Color? ink,
    Color? inkSoft, Color? inkFaint, Color? line, Color? surfaceAlt,
  }) {
    return Finan2Colors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      saving: saving ?? this.saving,
      savingTint: savingTint ?? this.savingTint,
      brandTint: brandTint ?? this.brandTint,
      brandDeep: brandDeep ?? this.brandDeep,
      userA: userA ?? this.userA,
      userB: userB ?? this.userB,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      line: line ?? this.line,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    );
  }

  @override
  Finan2Colors lerp(ThemeExtension<Finan2Colors>? other, double t) {
    if (other is! Finan2Colors) return this;
    return Finan2Colors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      saving: Color.lerp(saving, other.saving, t)!,
      savingTint: Color.lerp(savingTint, other.savingTint, t)!,
      brandTint: Color.lerp(brandTint, other.brandTint, t)!,
      brandDeep: Color.lerp(brandDeep, other.brandDeep, t)!,
      userA: Color.lerp(userA, other.userA, t)!,
      userB: Color.lerp(userB, other.userB, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      line: Color.lerp(line, other.line, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// TEMAS
// ─────────────────────────────────────────────────────────────────────────

abstract class Finan2Theme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        ground: Finan2Palette.groundLight,
        surface: Finan2Palette.surfaceLight,
        ink: Finan2Palette.inkLight,
        soft: Finan2Palette.inkSoftLight,
        line: Finan2Palette.lineLight,
        brand: Finan2Palette.brand,
        ext: Finan2Colors.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        ground: Finan2Palette.groundDark,
        surface: Finan2Palette.surfaceDark,
        ink: Finan2Palette.inkDark,
        soft: Finan2Palette.inkSoftDark,
        line: Finan2Palette.lineDark,
        brand: Finan2Palette.brandDarkMode,
        ext: Finan2Colors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color ground,
    required Color surface,
    required Color ink,
    required Color soft,
    required Color line,
    required Color brand,
    required Finan2Colors ext,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
    ).copyWith(primary: brand, surface: surface, onSurface: ink);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: ground,
      fontFamily: Finan2Type.fontFamily,
    );

    // Plus Jakarta Sans (local) aplicada sobre nuestra escala de tipos.
    final textTheme = Finan2Type.textTheme(ink: ink, soft: soft)
        .apply(fontFamily: Finan2Type.fontFamily);

    return base.copyWith(
      extensions: [ext],
      textTheme: textTheme,
      iconTheme: IconThemeData(color: ink, size: Finan2Sizes.iconMd),
      dividerColor: line,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: line),
          borderRadius: BorderRadius.circular(Finan2Radius.card),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Finan2Radius.field),
          ),
          textStyle: const TextStyle(
            fontFamily: Finan2Type.fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: ink,
          side: BorderSide(color: line),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Finan2Radius.field),
          ),
          textStyle: const TextStyle(
            fontFamily: Finan2Type.fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Finan2Radius.field),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Finan2Radius.field),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Finan2Radius.field),
          borderSide: BorderSide(color: brand, width: 1.6),
        ),
      ),
    );
  }
}
