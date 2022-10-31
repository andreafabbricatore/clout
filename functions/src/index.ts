/* eslint-disable max-len */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {firestore} from "firebase-admin";
admin.initializeApp();
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const db = admin.firestore();
const fcm = admin.messaging();

export const sendToDevice = functions.firestore.document("updates/{id}").onCreate(async (snapshot) => {
  const noti = snapshot.data();

  const querySnapshot = await db.collection("users").doc(noti.target).collection("tokens").get();

  const tokens = querySnapshot.docs.map((snap) => snap.id);

  const payload: admin.messaging.MessagingPayload = {
    notification: {
      title: noti.title,
      body: noti.description,
    },
  };

  await db.collection("users").doc(noti.target).set({"notifications": firestore.FieldValue.arrayUnion({"notification": noti.notification, "type": noti.type, "time": firestore.Timestamp.now()})}, {merge: true});

  await db.collection("updates").doc(snapshot.id).delete();

  return fcm.sendToDevice(tokens, payload);
});

