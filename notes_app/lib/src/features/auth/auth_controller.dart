import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
  }

  Future<String?> signUp(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      return 'Email and password cannot be empty';
    }

    if (trimmedPassword.length < 6) {
      return 'Password must be at least 6 characters';
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      
      // Send verification email
      await userCredential.user?.sendEmailVerification();
      
      // Sign out the user immediately after signup
      // They need to verify email before they can log in
      await _auth.signOut();
      
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign up';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> signIn(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      return 'Email and password cannot be empty';
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );
      
      // Check if email is verified
      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        // Sign out if email is not verified
        await _auth.signOut();
        return 'EMAIL_NOT_VERIFIED'; // Special code to trigger resend option
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign in';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No account found with this email address.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address.';
      }
      return e.message ?? 'Failed to send password reset email.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> resendVerificationEmail(String email, String password) async {
    try {
      // First, sign in to get the user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      final user = userCredential.user;
      if (user != null) {
        // Send verification email
        await user.sendEmailVerification();
        // Sign out again since email is not verified
        await _auth.signOut();
        return null;
      }
      return 'Failed to send verification email.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No account found with this email address.';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address.';
      }
      return e.message ?? 'Failed to send verification email.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get currentUserId => _user.value?.uid;
}
