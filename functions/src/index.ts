/* eslint-disable max-len */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {firestore} from "firebase-admin";
const stripe = require("stripe")(functions.config().stripe.testkey)
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

  const querySnapshot = await db.collection("users").where("uid", "in", noti.target).get();

  let finaltokens:string[] = [];

  querySnapshot.docs.map((snap) => finaltokens = finaltokens.concat(snap.data()?.tokens));

  const payload: admin.messaging.MessagingPayload = {
    notification: {
      title: "Clout",
      body: noti.description,
    }, data: {
      type: noti.type,
      eventid: noti.eventid,
      userid: noti.userid,
    },
  };

  querySnapshot.docs.forEach(async (element) => {
    await db.collection("users").doc(element.id).set({"notificationcounter": firestore.FieldValue.increment(1), "notifications": firestore.FieldValue.arrayUnion({"notification": noti.notification, "type": noti.type, "time": firestore.Timestamp.now(), "eventid": noti.eventid, "userid": noti.userid})}, {merge: true});
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

    const index = participants.indexOf(chat.senderuid);

    participants.splice(index, 1);

    const querySnapshot = await db.collection("users").where("uid", "in", participants).get();

    // console.log(querySnapshot);
    let finaltokens:string[] = [];

    querySnapshot.docs.map((snap) => finaltokens = finaltokens.concat(snap.data()?.tokens));
    if (chatdataSnapshot.data()?.type == "user") {
      const payload: admin.messaging.MessagingPayload = {
        notification: {
          title: chat.sender,
          body: chat.notification,
        }, data: {
          type: "chat",
          chatid: chatid,
        },
      };
      querySnapshot.docs.forEach(async (element) => {
        await db.collection("users").doc(element.id).set({"chatnotificationcounter": firestore.FieldValue.increment(1)}, {merge: true});
      });
      await db.collection("chats").doc(chatid).update({"mostrecentmessage": chat.sender + ": " + chat.content});
      return fcm.sendToDevice(finaltokens, payload);
    } else {
      const payload: admin.messaging.MessagingPayload = {
        notification: {
          title: chatdataSnapshot.data()?.chatname[0],
          body: chat.notification,
        }, data: {
          type: "chat",
          chatid: chatid,
        },
      };
      querySnapshot.docs.forEach(async (element) => {
        await db.collection("users").doc(element.id).set({"chatnotificationcounter": firestore.FieldValue.increment(1)}, {merge: true});
      });
      await db.collection("chats").doc(chatid).update({"mostrecentmessage": chat.sender + ": " + chat.content});
      return fcm.sendToDevice(finaltokens, payload);
    }
  } else {
    return;
  }
});

export const eventNotifyFollowers = functions.firestore.document("events/{id}").onCreate(async (snapshot) => {
  const event = snapshot.data();

  if (event.isinviteonly == false) {
    const hostdataSnapshot = await db.collection("users").doc(event.hostdocid).get();

    const followers:string[] = hostdataSnapshot.data()?.followers;

    const followersQuerySnapshot = await db.collection("users").where("uid", "in", followers).get();

    let finaltokens:string[] = [];

    followersQuerySnapshot.docs.forEach((doc) => {
      const userlat = doc.data()?.lastknownlat;
      const userlng = doc.data()?.lastknownlng;

      if (userlat < event.lat + 0.04 &&
        userlat > event.lat - 0.04 &&
        userlng < event.lng + 0.04 &&
        userlng > event.lng - 0.04) {
        finaltokens = finaltokens.concat(doc.data()?.tokens);
      }
    });

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: "Clout",
        body: hostdataSnapshot.data()?.fullname + " is now hosting " + event.title + " near you. Join them!",
      }, data: {
        type: "eventcreated",
        eventid: snapshot.id,
      },
    };
    if (finaltokens.length != 0) {
      return fcm.sendToDevice(finaltokens, payload);
    } else {
      return;
    }
  } else {
    return;
  }
});

export const StripePayEndpointMethodId = functions.https.onRequest(async (req, res) => {});
export const StripePayEndpointIntentId = functions.https.onRequest(async (req, res) => {});
