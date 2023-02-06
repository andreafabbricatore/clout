"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.eventNotifyFollowers = exports.chatsendToDevices = exports.sendToDevice = void 0;
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
    const querySnapshot = await db.collection("users").where("uid", "in", noti.target).get();
    let finaltokens = [];
    querySnapshot.docs.map((snap) => { var _a; return finaltokens = finaltokens.concat((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.tokens); });
    const payload = {
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
        await db.collection("users").doc(element.id).set({ "notificationcounter": firebase_admin_1.firestore.FieldValue.increment(1), "notifications": firebase_admin_1.firestore.FieldValue.arrayUnion({ "notification": noti.notification, "type": noti.type, "time": firebase_admin_1.firestore.Timestamp.now(), "eventid": noti.eventid, "userid": noti.userid }) }, { merge: true });
    });
    await db.collection("updates").doc(snapshot.id).delete();
    return fcm.sendToDevice(finaltokens, payload);
});
exports.chatsendToDevices = functions.firestore.document("chats/{chatid}/messages/{id}").onCreate(async (snapshot, context) => {
    var _a, _b, _c;
    const chat = snapshot.data();
    if (chat.sender != "server") {
        const chatid = context.params.chatid;
        const chatdataSnapshot = await db.collection("chats").doc(chatid).get();
        const participants = (_a = chatdataSnapshot.data()) === null || _a === void 0 ? void 0 : _a.participants;
        const index = participants.indexOf(chat.senderuid);
        participants.splice(index, 1);
        const querySnapshot = await db.collection("users").where("uid", "in", participants).get();
        // console.log(querySnapshot);
        let finaltokens = [];
        querySnapshot.docs.map((snap) => { var _a; return finaltokens = finaltokens.concat((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.tokens); });
        if (((_b = chatdataSnapshot.data()) === null || _b === void 0 ? void 0 : _b.type) == "user") {
            const payload = {
                notification: {
                    title: "Clout - " + chat.sender,
                    body: chat.notification,
                }, data: {
                    type: "chat",
                    chatid: chatid,
                },
            };
            return fcm.sendToDevice(finaltokens, payload);
        }
        else {
            const payload = {
                notification: {
                    title: "Clout - " + ((_c = chatdataSnapshot.data()) === null || _c === void 0 ? void 0 : _c.chatname[0]),
                    body: chat.notification,
                }, data: {
                    type: "chat",
                    chatid: chatid,
                },
            };
            querySnapshot.docs.forEach(async (element) => {
                await db.collection("users").doc(element.id).set({ "chatnotificationcounter": firebase_admin_1.firestore.FieldValue.increment(1) }, { merge: true });
            });
            return fcm.sendToDevice(finaltokens, payload);
        }
    }
    else {
        return;
    }
});
exports.eventNotifyFollowers = functions.firestore.document("events/{id}").onCreate(async (snapshot) => {
    var _a, _b;
    const event = snapshot.data();
    const hostdataSnapshot = await db.collection("users").doc(event.hostdocid).get();
    const followers = (_a = hostdataSnapshot.data()) === null || _a === void 0 ? void 0 : _a.followers;
    const followersQuerySnapshot = await db.collection("users").where("uid", "in", followers).get();
    let finaltokens = [];
    followersQuerySnapshot.docs.forEach((doc) => {
        var _a, _b, _c;
        const userlat = (_a = doc.data()) === null || _a === void 0 ? void 0 : _a.lastknownlat;
        const userlng = (_b = doc.data()) === null || _b === void 0 ? void 0 : _b.lastknownlng;
        if (userlat < event.lat + 0.04 &&
            userlat > event.lat - 0.04 &&
            userlng < event.lng + 0.04 &&
            userlng > event.lng - 0.04) {
            finaltokens = finaltokens.concat((_c = doc.data()) === null || _c === void 0 ? void 0 : _c.tokens);
        }
    });
    const payload = {
        notification: {
            title: "Clout",
            body: ((_b = hostdataSnapshot.data()) === null || _b === void 0 ? void 0 : _b.fullname) + " is now hosting " + event.title + " near you. Join them!",
        }, data: {
            type: "eventcreated",
            eventid: snapshot.id,
        },
    };
    if (finaltokens.length != 0) {
        return fcm.sendToDevice(finaltokens, payload);
    }
    else {
        return;
    }
});
//# sourceMappingURL=index.js.map