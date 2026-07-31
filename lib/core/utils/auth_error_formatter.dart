import 'package:firebase_auth/firebase_auth.dart';

String parseAuthErrorMessage(dynamic error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please check your credentials and try again.';
      case 'email-already-in-use':
        return 'An account with this email address already exists. Please log in instead.';
      case 'weak-password':
        return 'The password provided is too weak. Please enter a stronger password.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in your Firebase console. Please enable it in Firebase Console > Authentication > Sign-in method.';
      case 'api-key-not-valid':
      case 'invalid-api-key':
        return 'Invalid Firebase API Key. Please check your firebase_options.dart or google-services.json.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      default:
        final detail = (error.message != null && error.message!.isNotEmpty && error.message != 'Error')
            ? error.message!
            : 'Please verify Email/Password is enabled in Firebase Console.';
        return 'Firebase error (${error.code}): $detail';
    }
  }

  final rawStr = error.toString();
  final cleaned = rawStr.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll('Exception:', '').trim();

  if (cleaned.isEmpty || cleaned.toLowerCase() == 'error' || cleaned.toLowerCase() == 'exception') {
    return 'Authentication failed ($error). Please check your Firebase Console settings.';
  }

  return cleaned;
}
