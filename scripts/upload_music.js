/**
 * Script para subir canciones de assets/music/ a Firebase Storage + Firestore.
 *
 * COMPLETAMENTE AUTOMÁTICO — no requiere configuración manual por canción:
 *   - Escanea assets/music/ y detecta todos los MP3s
 *   - Lee la duración real desde los tags del archivo
 *   - Infiere título y artista desde el nombre del archivo
 *   - Infiere el mood desde palabras clave en el nombre del archivo
 *   - Salta canciones ya subidas (sin duplicar)
 *
 * USO:
 *   1. Coloca tu serviceAccountKey.json en esta carpeta (scripts/)
 *   2. Agrega los MP3s a ../assets/music/
 *   3. Ejecuta:  node upload_music.js
 *
 * MOODS detectados automáticamente por palabras clave en el nombre del archivo:
 *   romantic  → romantic, love, amor, romance, balada, heart, corazon, latido
 *   happy     → happy, alegr, cute, feliz, smile, fiesta, dance, walking, together
 *   motivated → motivat, energy, power, upbeat, run, strength, fuerza
 *   nostalgic → nostalg, memories, recuerdo, mother, madre, childhood, infancia, aube
 *   relaxed   → (por defecto si no hay coincidencia)
 */

const admin = require('firebase-admin');
const { parseFile } = require('music-metadata');
const fs = require('fs');
const path = require('path');

// ─── CONFIGURACIÓN ────────────────────────────────────────────────────────────

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'serviceAccountKey.json');
const MUSIC_DIR = path.join(__dirname, '..', 'assets', 'music');
const STORAGE_BUCKET =
  process.env.FIREBASE_STORAGE_BUCKET || 'yellowflowers-58d52.firebasestorage.app';
const FIRESTORE_DATABASE = 'amarillas';

// ─── INFERENCIA DE METADATOS ──────────────────────────────────────────────────

const MOOD_KEYWORDS = {
  romantic: ['romantic', 'love', 'amor', 'romance', 'balada', 'heart', 'corazon', 'latido', 'jazmin', 'midnight'],
  happy:    ['happy', 'alegr', 'cute', 'feliz', 'smile', 'fiesta', 'dance', 'walking', 'together', 'joy', 'bells', 'crystal'],
  motivated:['motivat', 'energy', 'power', 'upbeat', 'run', 'strength', 'fuerza', 'fight'],
  nostalgic:['nostalg', 'memories', 'recuerdo', 'mother', 'madre', 'childhood', 'infancia', 'aube', 'ton'],
};

/**
 * Infiere el mood desde el nombre del archivo.
 * Recorre cada mood en orden de prioridad y devuelve el primero que coincida.
 * Retorna 'relaxed' si no hay coincidencia.
 */
function inferMood(filename) {
  const lower = filename.toLowerCase();
  for (const [mood, keywords] of Object.entries(MOOD_KEYWORDS)) {
    if (keywords.some((kw) => lower.includes(kw))) return mood;
  }
  return 'relaxed';
}

/**
 * Infiere género musical desde el mood o palabras clave del filename.
 */
function inferGenre(filename, mood) {
  const lower = filename.toLowerCase();
  if (lower.includes('guitar') || lower.includes('acoustic')) return 'acoustic';
  if (lower.includes('piano'))  return 'piano';
  if (lower.includes('electr') || lower.includes('dance')) return 'electronic';
  if (lower.includes('pop'))    return 'pop';
  if (lower.includes('ambient') || lower.includes('bells')) return 'ambient';
  const moodGenres = { romantic: 'romantic', happy: 'pop', motivated: 'electronic', nostalgic: 'acoustic', relaxed: 'ambient' };
  return moodGenres[mood] || 'acoustic';
}

/**
 * Convierte un segmento kebab-case a "Title Case".
 * "crystal-bells-by-businessstar" → "Crystal Bells By Businessstar"
 */
function toTitleCase(str) {
  return str
    .split('-')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

/**
 * Parsea el nombre del archivo para extraer artista y título.
 *
 * Patrón Pixabay: {artist}-{title words}-{numeric_id}.mp3
 * Ejemplo: businessstar-crystal-bells-by-businessstar-324576.mp3
 *   → artist: "Businessstar", title: "Crystal Bells By Businessstar"
 *
 * Si el nombre no sigue el patrón, usa el nombre completo como título.
 */
function parseFilename(filename) {
  const base = filename.replace(/\.mp3$/i, '').replace(/_/g, '-');
  const parts = base.split('-');

  // Si el último segmento es numérico (ID de Pixabay), lo eliminamos
  const lastIsId = /^\d+$/.test(parts[parts.length - 1]);
  const meaningful = lastIsId ? parts.slice(0, -1) : parts;

  if (meaningful.length < 2) {
    return { artist: 'Unknown', title: toTitleCase(base) };
  }

  const artist = toTitleCase(meaningful[0]);
  const title = toTitleCase(meaningful.slice(1).join('-'));
  return { artist, title };
}

/**
 * Lee la duración real del MP3 en segundos usando music-metadata.
 * Retorna 0 si no puede leerla.
 */
async function readDuration(filePath) {
  try {
    const meta = await parseFile(filePath, { duration: true });
    return Math.round(meta.format.duration || 0);
  } catch {
    return 0;
  }
}

// ─── INICIALIZACIÓN ───────────────────────────────────────────────────────────

if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error('❌ No se encontró serviceAccountKey.json en scripts/');
  console.error('   Descárgalo desde: Firebase Console → Configuración → Cuentas de servicio');
  process.exit(1);
}

const serviceAccount = require(SERVICE_ACCOUNT_PATH);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: STORAGE_BUCKET,
});

const db = admin.firestore();
db.settings({ databaseId: FIRESTORE_DATABASE });
const bucket = admin.storage().bucket();

// ─── HELPERS FIREBASE ─────────────────────────────────────────────────────────

async function getExistingStoragePaths() {
  const snapshot = await db.collection('songs').select('storage_path').get();
  const paths = new Set();
  snapshot.docs.forEach((doc) => {
    const p = doc.data().storage_path;
    if (p) paths.add(p);
  });
  return paths;
}

async function uploadFile(localPath, storagePath) {
  await bucket.upload(localPath, {
    destination: storagePath,
    metadata: { contentType: 'audio/mpeg', cacheControl: 'public, max-age=31536000' },
  });
  await bucket.file(storagePath).makePublic();
  const encoded = storagePath.split('/').map(encodeURIComponent).join('/');
  return `https://storage.googleapis.com/${STORAGE_BUCKET}/${encoded}`;
}

// ─── LÓGICA PRINCIPAL ─────────────────────────────────────────────────────────

async function uploadMusic() {
  console.log('🌸 Flores Amarillas — Upload Music Script');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  if (!fs.existsSync(MUSIC_DIR)) {
    console.error(`❌ No se encontró el directorio: ${MUSIC_DIR}`);
    process.exit(1);
  }

  // Todos los MP3s en la carpeta
  const allFiles = fs.readdirSync(MUSIC_DIR).filter((f) => /\.mp3$/i.test(f));
  if (allFiles.length === 0) {
    console.log('⚠️  No hay archivos MP3 en assets/music/');
    process.exit(0);
  }

  // Canciones ya registradas en Firestore
  console.log('🔍 Verificando canciones ya subidas en Firestore...');
  const existingPaths = await getExistingStoragePaths();
  console.log(`   ${existingPaths.size} canción(es) ya registradas.\n`);

  // Separar nuevas de ya existentes
  const toProcess = [];
  for (const file of allFiles) {
    const mood = inferMood(file);
    const storagePath = `music/${mood}/${file}`;
    if (existingPaths.has(storagePath)) {
      const { title } = parseFilename(file);
      console.log(`⏭  Ya subida: ${title}`);
    } else {
      toProcess.push(file);
    }
  }

  console.log('');

  if (toProcess.length === 0) {
    console.log('✅ No hay canciones nuevas para subir. ¡Todo está al día!');
    process.exit(0);
  }

  console.log(`📤 Subiendo ${toProcess.length} canción(es) nueva(s)...\n`);

  const col = db.collection('songs');
  let uploaded = 0;
  let failed = 0;

  for (const file of toProcess) {
    const localPath = path.join(MUSIC_DIR, file);
    const mood = inferMood(file);
    const genre = inferGenre(file, mood);
    const storagePath = `music/${mood}/${file}`;
    const { artist, title } = parseFilename(file);
    const duration = await readDuration(localPath);

    process.stdout.write(`   ⬆  ${title} — ${artist} (${mood})...`);

    try {
      const audioUrl = await uploadFile(localPath, storagePath);

      await col.add({
        title,
        artist,
        audio_url: audioUrl,
        cover_url: '',
        duration,
        genre,
        mood,
        is_active: true,
        storage_path: storagePath,
        uploaded_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      uploaded++;
      console.log(` ✓  (${duration}s)`);
    } catch (err) {
      failed++;
      console.log(` ✗`);
      console.error(`      Error: ${err.message}`);
    }
  }

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`✅ ${uploaded} canción(es) subidas exitosamente.`);
  if (failed > 0) console.log(`❌ ${failed} fallaron — revisa los errores arriba.`);
  console.log('');

  process.exit(failed > 0 ? 1 : 0);
}

uploadMusic().catch((err) => {
  console.error('\n💥 Error inesperado:', err);
  process.exit(1);
});
