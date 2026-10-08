# Publicación automática (fastlane)

La app se publica con [fastlane](https://fastlane.tools) en:

| Plataforma | Lane | Destino |
| --- | --- | --- |
| iOS | `fastlane ios beta` | TestFlight / App Store Connect |
| Android | `fastlane android deploy` | Google Play, track `internal` (configurable) |
| Android | `fastlane android promote` | Pasa una versión de un track a otro, por ejemplo de `internal` a `production` |

La **versión** (`MAJOR.MINOR.PATCH`) se toma de `pubspec.yaml`. Súbela antes con
`scripts/bump_version.sh patch|minor|major`.

El **número de build** se calcula solo: es el mayor entre el de `pubspec.yaml` y
el último build que hay en la tienda más uno. Así nunca se repite.

---

## iOS sin Mac (GitHub Actions)

El workflow **Store Release** corre en las Mac de GitHub, así que no necesitas la tuya.
Cada push a `main` que cambie `pubspec.yaml` (es decir, una versión nueva) compila
la app y la sube a TestFlight. También puedes ejecutarlo a mano desde **Actions**.

Solo necesitas una API key de App Store Connect, que se crea desde el navegador:
1. En **App Store Connect → Usuarios y acceso → Integraciones → API de App Store Connect**,
   crea una clave de equipo con rol **Administrador** y descarga el `.p8`.
2. En GitHub, en **Settings → Secrets and variables → Actions**, crea `ASC_KEY_ID`,
   `ASC_ISSUER_ID` y `ASC_KEY_P8`. En `ASC_KEY_P8` pega el contenido del `.p8`; lo
   puedes abrir con cualquier editor de texto.

La firma usa **fastlane match**: un certificado *Apple Distribution* y un perfil
*App Store* guardados cifrados en un repositorio privado. match los crea la primera
vez con la API key, sin necesidad de Mac. Para eso también necesitas:
3. Un repositorio **privado** vacío, por ejemplo `GrullonDev/certificates`.
4. Los secrets `MATCH_GIT_URL` (por ejemplo `https://github.com/GrullonDev/certificates.git`),
   `MATCH_PASSWORD` (una contraseña que elijas para cifrar los certificados) y
   `MATCH_GIT_TOKEN` (un token personal de GitHub con permiso *Contents: read and write*
   sobre ese repositorio).

Usa **o** GitHub Actions **o** Xcode Cloud. Si activas los dos, cada versión se sube dos veces.

---

## 0. iOS con Xcode Cloud (deploy automático con cada push)

Es el mismo esquema de PersonalFinance. Xcode Cloud compila y sube a TestFlight
cada vez que haces push a la rama que elijas. El script
`ios/ci_scripts/ci_post_clone.sh` hace lo siguiente:
- instala Flutter (la versión de `.fvmrc`),
- ejecuta `flutter pub get` y `pod install`,
- usa `CI_BUILD_NUMBER` de Xcode Cloud como número de build, para que nunca se repita.

Configuración, una sola vez, desde Xcode en tu Mac:
1. Abre `ios/Runner.xcworkspace` → **Product → Xcode Cloud → Create Workflow**.
2. Elige el producto **Runner** y da acceso a GitHub al repo `GrullonDev/YellowFlowers`.
3. **Start Condition:** *Branch Changes* en `main`, o en la rama de la que quieras publicar.
4. **Actions:** *Archive* (iOS), con *Distribution Preparation* en **App Store Connect**.
5. **Post-Actions:** *TestFlight Internal Testing*, y elige tu grupo de testers.
6. Opcional, en **Environment:** `FLUTTER_VERSION` si quieres otra versión de Flutter distinta a la de `.fvmrc`.

Para publicar una versión nueva:
1. Sube la versión en `pubspec.yaml`, por ejemplo con `scripts/bump_version.sh patch`.
2. Haz commit y push a la rama del workflow.

Xcode Cloud compila y la sube a TestFlight.

---

## 1. Ejecutar desde GitHub Actions

En **Actions → Store Release → Run workflow** elige:
- `platform`: `both`, `ios` o `android`.
- `android_track`: `internal`, `alpha`, `beta` o `production`.
- `android_status`: `completed`. Usa `draft` si la app todavía no está publicada en Google Play; en ese caso Google solo acepta borradores.

## 2. Ejecutar desde tu Mac

```bash
bundle install                       # una sola vez

# iOS
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export ASC_KEY_PATH=~/keys/AuthKey_XXXXXXXXXX.p8
bundle exec fastlane ios beta

# Android (requiere android/key.properties y el keystore)
export PLAY_JSON_KEY_PATH=~/keys/play-service-account.json
bundle exec fastlane android deploy                  # track internal
bundle exec fastlane android deploy track:beta
bundle exec fastlane android promote from:internal to:production
```

---

## 3. Secrets de GitHub

Se configuran en **Settings → Secrets and variables → Actions → New repository secret**.

### iOS (App Store Connect)

| Secret | Qué es |
| --- | --- |
| `ASC_KEY_ID` | Key ID de la API key |
| `ASC_ISSUER_ID` | Issuer ID (aparece arriba de la lista de keys) |
| `ASC_KEY_P8` | Contenido del archivo `.p8` tal cual, incluidas las líneas `-----BEGIN PRIVATE KEY-----` y `-----END PRIVATE KEY-----`. También se acepta `ASC_KEY_P8_BASE64` con el archivo en base64. |

Para crear la key: **App Store Connect → Usuarios y acceso → Integraciones →
API de App Store Connect → Claves del equipo → +**, con rol **Administrador**.

| `MATCH_GIT_URL` | URL HTTPS del repositorio privado de certificados |
| `MATCH_PASSWORD` | Contraseña con la que match cifra el certificado y el perfil |
| `MATCH_GIT_TOKEN` | Token personal de GitHub con acceso de lectura y escritura al repo de certificados |

El rol Administrador es necesario para que match pueda crear el certificado de
distribución y el perfil de App Store con la API key. El `.p8` solo se puede
descargar una vez; guárdalo en un lugar seguro. Si pierdes `MATCH_PASSWORD`,
borra el repo de certificados y match los vuelve a crear.

### Android (Google Play)

Con estos secrets, cada push a `main` que cambie `pubspec.yaml` también sube el
App Bundle a la pista **internal** de Google Play. Sin ellos, el job de Android
se omite con un aviso y iOS se publica igual. Desde **Actions → Store Release →
Run workflow** puedes elegir otra pista (`alpha`, `beta`, `production`).

| Secret | Qué es |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Keystore de carga (`android/app/upload-keystore.jks`) en base64 |
| `ANDROID_KEYSTORE_PASSWORD` | Contraseña del keystore (`STORE_PASSWORD` del `.env`) |
| `ANDROID_KEY_PASSWORD` | Contraseña de la llave (`KEY_PASSWORD` del `.env`) |
| `ANDROID_KEY_ALIAS` | Opcional. Alias de la llave; por defecto `upload` |
| `PLAY_SERVICE_ACCOUNT_JSON` | Contenido completo del JSON de la cuenta de servicio |

Para sacar el base64 del keystore, sin saltos de línea:
- Windows (PowerShell): `[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\upload-keystore.jks")) | Set-Clipboard`
- Mac: `base64 -i android/app/upload-keystore.jks | pbcopy`

No uses `certutil -encode`: agrega encabezados que rompen el archivo.

Antes de compilar, el workflow comprueba que la SHA-1 del keystore sea la del
certificado de carga registrado en Play Console (`UPLOAD_CERT_SHA1` en
`.github/workflows/store-release.yml`). Si algún día se cambia la llave de carga,
actualiza ese valor.

Para crear la cuenta de servicio:
1. En **Google Cloud Console**, en el proyecto de Firebase de la app, ve a
   **IAM y administración → Cuentas de servicio → Crear cuenta de servicio**.
   No necesita roles de Cloud. Después, en **Claves → Agregar clave → JSON**,
   descarga la clave.
2. Habilita la **Google Play Android Developer API** en ese mismo proyecto.
3. En **Play Console → Usuarios y permisos → Invitar usuarios**, invita el correo de
   la cuenta de servicio y dale permisos sobre la app (ver la app, administrar
   versiones de prueba y de producción).
4. Pega el contenido del JSON en el secret `PLAY_SERVICE_ACCOUNT_JSON`.

El `versionCode` lo calcula fastlane: es el mayor entre el número de build de
`pubspec.yaml` y el último `versionCode` en Play más uno.

---

## Notas

- Nunca subas al repositorio el `.p8`, el keystore, `key.properties` ni el JSON de la
  cuenta de servicio. Ya están en `.gitignore`.
- En Android, `android/app/build.gradle` toma el `versionCode` de la variable
  `BUILD_NUMBER`, que el lane `android deploy` define antes de compilar.
- El workflow `android-release.yml` (Firebase App Distribution) solo se ejecuta a
  mano y es independiente de este.
