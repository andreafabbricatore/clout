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

  const querySnapshot = await db.collection("users").where("docid", "in", noti.target).get();

  let finaltokens:string[] = [];

  querySnapshot.docs.map((snap) => finaltokens = finaltokens.concat(snap.data()?.tokens));

  const payload: admin.messaging.MessagingPayload = {
    notification: {
      title: "Clout",
      body: noti.description,
    },
  };

  querySnapshot.docs.forEach(async (element) => {
    await db.collection("users").doc(element.id).set({"notifications": firestore.FieldValue.arrayUnion({"notification": noti.notification, "type": noti.type, "time": firestore.Timestamp.now()})}, {merge: true});
  });

  await db.collection("updates").doc(snapshot.id).delete();

  return fcm.sendToDevice(finaltokens, payload);
});

export const chatsendToDevices = functions.firestore.document("chats/{chatid}/messages/{id}").onCreate(async (snapshot, context) => {
  const chat = snapshot.data();

  if (chat.sender != "server") {
    const chatid = context.params.chatid;

    const chatdataSnapshot = await db.collection("chats").doc(chatid).get();

    const participants:string[] = chatdataSnapshot.data()?.participants;

    const querySnapshot = await db.collection("users").where("docid", "in", participants).get();

    // console.log(querySnapshot);
    let finaltokens:string[] = [];

    querySnapshot.docs.map((snap) => finaltokens = finaltokens.concat(snap.data()?.tokens));

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: "Clout - " + chat.chatname,
        body: chat.notification,
      },
    };

    return fcm.sendToDevice(finaltokens, payload);
  } else {
    return;
  }
});
