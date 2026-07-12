// Background FCM message handler, required by firebase_messaging on web -
// receives pushes while the PWA/tab isn't in the foreground. The values
// below are the same public web config already in lib/firebase_options.dart
// (Firebase web API keys are meant to be client-visible; access is enforced
// by Firestore/Storage security rules, not by hiding this).

importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDYBubJDo8RW0fX45xLZqkn9gyWBg39TLU',
  appId: '1:1048748616099:web:58dc1f4d00263d626c5216',
  messagingSenderId: '1048748616099',
  projectId: 'finan2',
  authDomain: 'finan2.firebaseapp.com',
  storageBucket: 'finan2.firebasestorage.app',
});

firebase.messaging();
