import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Lightweight anonymous-first auth layer.
///
/// The app has no login screen and no reason to force one — anonymous
/// Firebase Auth gives every install a stable `uid` for free, which is
/// all that's needed to sync user-composed content (special messages,
/// and later the moments gallery) to Firestore instead of losing it on
/// reinstall. If the user later wants to link a real account (Google/
/// Apple/email) to avoid losing data on device change, that can be
/// layered on top of the same anonymous uid via `linkWithCredential`
/// without migrating any data.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  String? get uid => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;

  /// Signs in anonymously if there's no current user yet. Safe to call
  /// on every cold start — a no-op if already signed in. Never throws;
  /// sync features should treat a null return as "stay local-only for
  /// now" rather than blocking app startup.
  Future<String?> ensureSignedIn() async {
    try {
      if (_auth.currentUser != null) return _auth.currentUser!.uid;
      final credential = await _auth.signInAnonymously();
      return credential.user?.uid;
    } catch (e) {
      debugPrint('AuthService: anonymous sign-in failed: $e');
      return null;
    }
  }
}
