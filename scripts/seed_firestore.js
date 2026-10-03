/**
 * Script para poblar la colección `songs` en Firestore.
 *
 * USO:
 *   1. Instala las dependencias:  npm install firebase-admin
 *   2. Descarga tu serviceAccountKey.json desde Firebase Console
 *      → Configuración del proyecto → Cuentas de servicio → Generar nueva clave privada
 *   3. Ejecuta:  node seed_firestore.js
 *
 * ESTRUCTURA DE CADA DOCUMENTO:
 *   - id        : auto-generado por Firestore
 *   - title     : String  — nombre de la canción
 *   - artist    : String  — artista
 *   - audio_url : String  — URL de Firebase Storage (gsutil URL convertida a download URL)
 *   - cover_url : String  — URL de la portada (Storage o imagen externa royalty-free)
 *   - duration  : Number  — duración en segundos
 *   - genre     : String  — género musical
 *   - mood      : String  — relaxed | romantic | motivated | nostalgic | happy
 *   - is_active : Boolean — true para que sea visible en la app
 *
 * NOTA SOBRE AUDIO:
 *   Sube los archivos .mp3 a Firebase Storage en la ruta:
 *     music/{mood}/{nombre_archivo}.mp3
 *   Luego obtén la Download URL desde la consola y pégala en audio_url.
 *
 *   Fuentes de música royalty-free para uso comercial:
 *     - https://pixabay.com/music/
 *     - https://mixkit.co/free-music/
 *     - https://ccmixter.org/
 *     - https://www.bensound.com/ (verificar licencia comercial)
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ─── CANCIONES DE EJEMPLO ────────────────────────────────────────────────────
// Reemplaza audio_url y cover_url con las URLs reales de tu Firebase Storage
const songs = [
  // MOOD: relaxed
  {
    title: 'Morning Calm',
    artist: 'Bensound',
    audio_url: 'https://storage.googleapis.com/music/relaxed/morning_calm.mp3',
    cover_url: 'https://storage.googleapis.com/covers/relaxed/morning_calm.jpg',
    duration: 185,
    genre: 'acoustic',
    mood: 'relaxed',
    is_active: true,
  },
  {
    title: 'Sunny',
    artist: 'Bensound',
    audio_url: 'https://storage.googleapis.com/music/relaxed/sunny.mp3',
    cover_url: 'https://storage.googleapis.com/covers/relaxed/sunny.jpg',
    duration: 210,
    genre: 'acoustic',
    mood: 'relaxed',
    is_active: true,
  },

  // MOOD: romantic
  {
    title: 'Love',
    artist: 'Bensound',
    audio_url: 'https://storage.googleapis.com/music/romantic/love.mp3',
    cover_url: 'https://storage.googleapis.com/covers/romantic/love.jpg',
    duration: 198,
    genre: 'piano',
    mood: 'romantic',
    is_active: true,
  },
  {
    title: 'Tenderness',
    artist: 'Bensound',
    audio_url: 'https://storage.googleapis.com/music/romantic/tenderness.mp3',
    cover_url: 'https://storage.googleapis.com/covers/romantic/tenderness.jpg',
    duration: 222,
    genre: 'piano',
    mood: 'romantic',
    is_active: true,
  },

  // MOOD: motivated
  {
    title: 'Energy',
    artist: 'Bensound',
    audio_url: 'https://storage.googleapis.com/music/motivated/energy.mp3',
    cover_url: 'https://storage.googleapis.com/covers/motivated/energy.jpg',
    duration: 174,
    genre: 'pop',
    mood: 'motivated',
    is_active: true,
  },
  {
    title: 'Upbeat',
    artist: 'Mixkit',
    audio_url: 'https://storage.googleapis.com/music/motivated/upbeat.mp3',
    cover_url: 'https://storage.googleapis.com/covers/motivated/upbeat.jpg',
    duration: 165,
    genre: 'electronic',
    mood: 'motivated',
    is_active: true,
  },

  // MOOD: nostalgic
  {
    title: 'Memories',
    artist: 'Bensound',
    audio_url: 'https://storage.googleapis.com/music/nostalgic/memories.mp3',
    cover_url: 'https://storage.googleapis.com/covers/nostalgic/memories.jpg',
    duration: 240,
    genre: 'softrock',
    mood: 'nostalgic',
    is_active: true,
  },

  // MOOD: happy
  {
    title: 'Happiness',
    artist: 'Bensound',
    audio_url: 'https://storage.googleapis.com/music/happy/happiness.mp3',
    cover_url: 'https://storage.googleapis.com/covers/happy/happiness.jpg',
    duration: 192,
    genre: 'happy',
    mood: 'happy',
    is_active: true,
  },
  {
    title: 'Cute',
    artist: 'Bensound',
    audio_url: 'https://storage.googleapis.com/music/happy/cute.mp3',
    cover_url: 'https://storage.googleapis.com/covers/happy/cute.jpg',
    duration: 163,
    genre: 'indiepop',
    mood: 'happy',
    is_active: true,
  },
];

async function seed() {
  const col = db.collection('songs');
  let count = 0;
  for (const song of songs) {
    await col.add(song);
    count++;
    console.log(`✓ [${count}/${songs.length}] ${song.title} — ${song.mood}`);
  }
  console.log(`\n✅ ${count} canciones agregadas a Firestore.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Error:', err);
  process.exit(1);
});
