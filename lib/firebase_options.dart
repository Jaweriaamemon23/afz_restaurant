// Firebase configuration for AFZ Restaurant

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD11bQrTxO1UpxSnD5MZCxPMppkEIFJqYg',
    appId: '1:739896266270:web:041d541a009543217d680f',
    messagingSenderId: '739896266270',
    projectId: 'afz-restaurant',
    authDomain: 'afz-restaurant.firebaseapp.com',
    storageBucket: 'afz-restaurant.firebasestorage.app',
    measurementId: 'G-CCCNL057KB',
  );

  static FirebaseOptions get currentPlatform {
    return web;
  }
}
