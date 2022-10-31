"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendToDevice = void 0;
/* eslint-disable max-len */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const firebase_admin_1 = require("firebase-admin");
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
exports.sendToDevice = functions.firestore.document("updates/{id}").onCreate(async (snapshot) => {
    const noti = snapshot.data();
    const querySnapshot = await db.collection("users").doc(noti.target).collection("tokens").get();
    const tokens = querySnapshot.docs.map((snap) => snap.id);
    const payload = {
        notification: {
            title: noti.title,
            body: noti.description,
        },
    };
    await db.collection("users").doc(noti.target).set({ "notifications": firebase_admin_1.firestore.FieldValue.arrayUnion({ "notification": noti.notification, "type": noti.type, "time": firebase_admin_1.firestore.Timestamp.now() }) }, { merge: true });
    await db.collection("updates").doc(snapshot.id).delete();
    return fcm.sendToDevice(tokens, payload);
});
//# sourceMappingURL=index.js.map