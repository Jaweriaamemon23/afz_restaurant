
importScripts(
  'https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js'
);
importScripts(
  'https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: 'AIzaSyD11bQrTxO1UpxSnD5MZCxPMppkEIFJqYg',
  appId: '1:739896266270:web:041d541a009543217d680f',
  messagingSenderId: '739896266270',
  projectId: 'afz-restaurant',
  authDomain: 'afz-restaurant.firebaseapp.com',
  storageBucket: 'afz-restaurant.firebasestorage.app',
  measurementId: 'G-CCCNL057KB',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || 'AFZ Restaurant';
  const options = {
    body: payload.notification?.body || 'Your order has an update.',
    icon: '/icons/Icon-192.png',
  };

  self.registration.showNotification(title, options);
});
