import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn(scopes: const ['email']);

  Stream<User?> get userChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  /// เข้าสู่ระบบด้วยบัญชี Google
  /// คืน null ถ้าผู้ใช้กดยกเลิกเอง (ไม่ถือเป็น error)
  Future<User?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) return null; // ผู้ใช้ยกเลิก

    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
}
