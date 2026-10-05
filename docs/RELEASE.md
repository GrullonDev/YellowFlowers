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
| `ASC_KEY_P8_BASE64` | El archivo `.p8` en base64: `base64 -i AuthKey_XXXX.p8 \| pbcopy` |

Para crear la key: **App Store Connect → Usuarios y acceso → Integraciones →
API de App Store Connect → Claves del equipo → +**, con rol **Administrador**.

El rol Administrador es necesario porque la firma es **automática en la nube**:
Xcode crea o descarga el certificado y el perfil de distribución usando esta key,
así que no hace falta subir certificados `.p12` ni perfiles. El `.p8` solo se
puede descargar una vez; guárdalo en un lugar seguro.

### Android (Google Play)

| Secret | Qué es |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Keystore de subida en base64: `base64 -i upload-keystore.jks \| pbcopy` |
| `ANDROID_KEYSTORE_PASSWORD` | Contraseña del keystore (`storePassword`) |
| `ANDROID_KEY_ALIAS` | Alias de la llave (`keyAlias`) |
| `ANDROID_KEY_PASSWORD` | Contraseña de la llave (`keyPassword`) |
| `PLAY_SERVICE_ACCOUNT_JSON` | Contenido completo del JSON de la cuenta de servicio |

Para crear la cuenta de servicio:
1. En **Google Cloud Console** crea una cuenta de servicio en el proyecto vinculado a
   Play Console y descarga una clave JSON.
2. En **Play Console → Usuarios y permisos → Invitar usuarios**, invita el correo de
   la cuenta de servicio y dale permisos sobre la app "Amarillas" (publicar en pistas
   de prueba y producción).
3. Pega el contenido del JSON en el secret `PLAY_SERVICE_ACCOUNT_JSON`.

> La **primera** subida de una app nueva a Google Play debe hacerse a mano desde
> Play Console. A partir de la segunda, fastlane puede subirla.

---

## Notas

- Nunca subas al repositorio el `.p8`, el keystore, `key.properties` ni el JSON de la
  cuenta de servicio. Ya están en `.gitignore`.
- En Android, `android/app/build.gradle` toma el `versionCode` de la variable
  `BUILD_NUMBER`, que el lane `android deploy` define antes de compilar.
- El workflow anterior `android-release.yml` (Firebase App Distribution) sigue igual
  y es independiente de este.
