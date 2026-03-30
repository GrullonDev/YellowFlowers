// Global constants used across the app

/// Destination URL encoded into the QR code on the Story card.
const String kQrCodeUrl = 'https://jorgegrullondev.com/';

/// Jamendo API Client ID (register at https://devportal.jamendo.com/)
/// Prefer providing it via --dart-define=JAMENDO_CLIENT_ID=xxxx at build/run time.
/// Falls back to a placeholder if not provided.
const String kJamendoClientId = String.fromEnvironment(
  'JAMENDO_CLIENT_ID',
  defaultValue: '5f4b0a1e',
);
