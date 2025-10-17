// Minimal firebase options for web platform.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get web => const FirebaseOptions(
        apiKey: "AIzaSyAi4ZP3_a-FU71yxnsnvzYDSGb2ahrnFhQ",
        authDomain: "focus-me-ea8e2.firebaseapp.com",
        projectId: "focus-me-ea8e2",
        storageBucket: "focus-me-ea8e2.appspot.com",
        messagingSenderId: "953922363551",
        appId: "1:953922363551:web:a406bc7443660a4d8e82aa",
        measurementId: "G-PQJ77Y69KH",
      );

  static FirebaseOptions get currentPlatform => web;
}
