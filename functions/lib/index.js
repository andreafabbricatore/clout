"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.chatsendToDevices = exports.sendToDevice = void 0;
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
            title: "Clout",
            body: noti.description,
        },
    };
    await db.collection("users").doc(noti.target).set({ "notifications": firebase_admin_1.firestore.FieldValue.arrayUnion({ "notification": noti.notification, "type": noti.type, "time": firebase_admin_1.firestore.Timestamp.now() }) }, { merge: true });
    await db.collection("updates").doc(snapshot.id).delete();
    return fcm.sendToDevice(tokens, payload);
});
exports.chatsendToDevices = functions.firestore.document("chats/{chatid}/messages/{id}").onCreate(async (snapshot, context) => {
    var _a;
    const chat = snapshot.data();
    if (chat.sender != "server") {
        const chatid = context.params.chatid;
        const chatdataSnapshot = await db.collection("chats").doc(chatid).get();
        const participants = (_a = chatdataSnapshot.data()) === null || _a === void 0 ? void 0 : _a.participants;
        const querySnapshot = await db.collection("users").where("docid", "in", participants).get();
        // console.log(querySnapshot);
        let finaltokens = [];
        querySnapshot.docs.map((snap) => { var _a; return finaltokens = finaltokens.concat((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.tokens); });
        const payload = {
            notification: {
                title: "Clout - " + chat.chatname,
                body: chat.notification,
            },
        };
        return fcm.sendToDevice(finaltokens, payload);
    }
    else {
        return;
    }
});
//# sourceMappingURL=index.js.map