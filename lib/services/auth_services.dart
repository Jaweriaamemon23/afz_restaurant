import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ----------------------------------------------------------
  // REGISTER
  // ----------------------------------------------------------
  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? user = userCredential.user;

      if (user == null) {
        return 'Unable to create account.';
      }

      // Keep the name in Firebase Authentication temporarily.
      await user.updateDisplayName(fullName.trim());

      // Send verification email.
      await user.sendEmailVerification();

      // IMPORTANT:
      // Do NOT create Firestore document here.
      // Firestore will be created only after email verification.

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';

        case 'operation-not-allowed':
          return 'Email/password authentication is not enabled.';

        default:
          return e.message ?? 'Registration failed.';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ----------------------------------------------------------
  // CHECK VERIFICATION AND CREATE FIRESTORE PROFILE
  // ----------------------------------------------------------
  Future<String?> completeRegistration({required String role}) async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        return 'Your registration session has expired. Please register again.';
      }

      // Refresh Firebase user information.
      await user.reload();

      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        return 'Unable to find your account.';
      }

      // Check whether email has actually been verified.
      if (!currentUser.emailVerified) {
        return 'Please verify your email first.';
      }

      // Email is verified.
      // NOW create the Firestore profile.
      await _firestore.collection('users').doc(currentUser.uid).set({
        'fullName': currentUser.displayName ?? '',
        'email': currentUser.email ?? '',
        'role': role,
        'phone': '',
        'photoUrl': '',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Registration is complete.
      // Sign out so the user can login normally.
      await _auth.signOut();

      return null;
    } on FirebaseException catch (e) {
      return e.message ?? 'Could not complete registration.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ----------------------------------------------------------
  // CHECK EMAIL VERIFICATION
  // ----------------------------------------------------------
  Future<bool> checkEmailVerified() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      await user.reload();

      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // ----------------------------------------------------------
  // RESEND VERIFICATION EMAIL
  // ----------------------------------------------------------
  Future<String?> resendVerificationEmail() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        return 'No registration session found.';
      }

      await user.reload();

      if (user.emailVerified) {
        return 'Your email is already verified.';
      }

      await user.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not send verification email.';
    }
  }

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      final User? user = userCredential.user;

      if (user == null) {
        return null;
      }

      await user.reload();

      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        return null;
      }

      // Email must be verified before login.
      if (!currentUser.emailVerified) {
        await _auth.signOut();

        throw FirebaseAuthException(
          code: 'email-not-verified',
          message:
              'Please verify your email before logging in. Check your inbox.',
        );
      }

      // Get the user's Firestore profile.
      final DocumentSnapshot<Map<String, dynamic>> userDocument =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDocument.exists) {
        await _auth.signOut();

        throw FirebaseAuthException(
          code: 'user-profile-not-found',
          message: 'Your account profile was not found.',
        );
      }

      final data = userDocument.data();

      if (data == null) {
        await _auth.signOut();
        return null;
      }

      final bool isActive = data['isActive'] ?? true;

      if (!isActive) {
        await _auth.signOut();

        throw FirebaseAuthException(
          code: 'account-disabled',
          message: 'Your account has been disabled.',
        );
      }

      return {
        'uid': currentUser.uid,
        'fullName': data['fullName'] ?? '',
        'email': data['email'] ?? currentUser.email ?? '',
        'role': data['role'] ?? 'Customer',
      };
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw FirebaseAuthException(
            code: e.code,
            message: 'No account exists with this email.',
          );

        case 'wrong-password':
        case 'invalid-credential':
          throw FirebaseAuthException(
            code: e.code,
            message: 'Incorrect email or password.',
          );

        case 'invalid-email':
          throw FirebaseAuthException(
            code: e.code,
            message: 'Please enter a valid email address.',
          );

        case 'email-not-verified':
        case 'user-profile-not-found':
        case 'account-disabled':
          throw e;

        default:
          throw FirebaseAuthException(
            code: e.code,
            message: e.message ?? 'Login failed.',
          );
      }
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> logout() async {
    await _auth.signOut();
  }
}
