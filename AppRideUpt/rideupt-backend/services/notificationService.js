// services/notificationService.js
const admin = require('firebase-admin');
const User = require('../models/User');

const initializeFCM = () => {
  const serviceAccount = require('../config/firebase-service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('Firebase Admin SDK inicializado.');
};

const sendPushNotification = async (userId, title, body, data = {}) => {
  try {
    const user = await User.findById(userId);
    if (!user || !user.fcmToken) {
      console.log(`Usuario ${userId} no encontrado o sin token FCM.`);
      return;
    }

    const message = {
      notification: { title, body },
      data: data,
      token: user.fcmToken,
    };

    const response = await admin.messaging().send(message);
    console.log('Notificación enviada exitosamente:', response);
  } catch (error) {
    console.error('Error enviando notificación push:', error);
  }
};

module.exports = { initializeFCM, sendPushNotification };