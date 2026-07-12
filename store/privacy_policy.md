# Política de privacidad de Finan2

_Última actualización: 12 de julio de 2026._

Finan2 es una app de finanzas para un hogar de 2 personas. Esta página explica qué datos
recopila, para qué los usa, y qué no hace con ellos.

## Quién recopila los datos

Finan2 (Katanalabs). Contacto: **katanalabs.6002@gmail.com**.

## Qué datos recopilamos

**Al crear tu cuenta** (correo/contraseña o Google Sign-In, vía Firebase Authentication):
- Correo electrónico
- Nombre para mostrar y foto de perfil (si entras con Google)

**Al usar la app**, dentro del hogar compartido con tu pareja:
- Transacciones, cuentas, presupuesto, deudas, metas de ahorro, inversiones, facturas
  recurrentes, transferencias y notas del mes que registres
- Quién de los 2 miembros del hogar registró cada dato (para mostrar el autor)

**Para las notificaciones push**, el token de notificación de tu dispositivo (FCM), asociado
a tu hogar.

Finan2 **no** recopila ubicación, contactos, ni datos de pago con tarjeta - los "montos" que
registras son texto que tú escribes, no una integración con tu banco.

## Cómo protegemos los montos

Los campos de dinero (monto de cada transacción, saldos de cuenta, deudas, metas de ahorro,
inversiones, presupuesto) se cifran en tu dispositivo con AES-256 antes de subirse a la base
de datos. La llave de cifrado se genera al crear el hogar y **nunca se envía a nuestros
servidores** - vive solo en los dispositivos de los 2 miembros del hogar. Ni el equipo detrás
de Finan2, con acceso administrativo completo a la base de datos, puede leer los montos
reales de un hogar.

Nombres de categorías, cuentas, deudas, metas, descripciones de transacciones y notas de
texto **no** están cifrados en esta versión - se almacenan de forma segura (acceso
restringido solo a los 2 miembros del hogar, en tránsito y en reposo vía la infraestructura
de Google Cloud) pero son legibles con acceso administrativo a la base de datos.

## Con quién compartimos datos

Con nadie fuera de tu hogar. Tus datos solo son visibles para el otro miembro de tu mismo
hogar (máximo 2 personas por hogar).

Usamos los siguientes proveedores de infraestructura para operar la app - ellos procesan los
datos en nuestro nombre, no los usan para sus propios fines:
- **Google Firebase** (Authentication, Cloud Firestore, Cloud Messaging) - aloja tu cuenta y
  tus datos.
- **Cloudflare Workers** - reenvía las notificaciones push a Firebase Cloud Messaging; no
  almacena tus datos financieros, solo el título/cuerpo de la notificación en tránsito.

No vendemos datos a terceros. No mostramos anuncios. No usamos herramientas de analítica o
rastreo de terceros.

## Cuánto tiempo guardamos tus datos

Mientras tu cuenta y tu hogar existan. Si dejas el hogar (`Ajustes > Salir del hogar`), se
elimina tu membresía pero los datos del hogar permanecen para el otro miembro (son datos
compartidos, no exclusivamente tuyos). Si eliminas tu cuenta (`Ajustes > Eliminar cuenta`),
se borra tu usuario de autenticación; los datos del hogar compartido permanecen mientras el
otro miembro siga usándolo.

## Tus derechos

Puedes pedirnos en cualquier momento, escribiendo a katanalabs.6002@gmail.com, que
eliminemos por completo los datos de un hogar (incluyendo los de ambos miembros) una vez que
ninguno lo use.

## Menores de edad

Finan2 no está dirigida a menores de 13 años.

## Cambios a esta política

Si cambia algo importante en cómo manejamos tus datos, actualizaremos esta página y la fecha
de arriba.
