const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require('axios')
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
    let finaltokens = [];
    try {
        const querySnapshot = await db.collection("users").where("uid", "in", noti.target).get();
        querySnapshot.docs.map((snap) => { var _a; return finaltokens = finaltokens.concat((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.tokens); });
    } catch(e) {}
    
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
    if (noti.type != 'deleted') {
        try {
            querySnapshot.docs.forEach(async (element) => {
                await db.collection("users").doc(element.id).set({ "notificationcounter": admin.firestore.FieldValue.increment(1), "notifications": admin.firestore.FieldValue.arrayUnion({ "notification": noti.notification, "type": noti.type, "time": admin.firestore.Timestamp.now(), "eventid": noti.eventid, "userid": noti.userid }) }, { merge: true });
            });
        } catch(e) {}
    }
    if (noti.type == "modified") {
        const eventSnapshot = await db.collection("events").doc(noti.eventid).get();
        var event = eventSnapshot.data();
        const cronjobid = event.cronjobid;
        console.log(cronjobid);
        var eventdate = new Date(event.time.seconds*1000)
        eventdate.setHours(eventdate.getHours() - 1);
        var postData = {
            "job": {
                "schedule": {
                    "timezone": "Europe/London",
                    "hours": [eventdate.getUTCHours()+1],
                    "mdays": [eventdate.getUTCDate()],
                    "minutes": [eventdate.getUTCMinutes()],
                    "months": [eventdate.getUTCMonth()+1],
                    "wdays": [eventdate.getUTCDay()]
                },
            }
        };
        console.log(postData);
        axios.patch("https://api.cron-job.org/jobs/" + cronjobid, postData, {headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer sIdSzuqiTxr1TEX24M08U2H8ufFmBpxnjlfLKJpw32A="
        }});
    } else if (noti.type == "deleted") {
        const cronjobid = noti.cronjobid;
        axios.delete("https://api.cron-job.org/jobs/" + cronjobid, {headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer sIdSzuqiTxr1TEX24M08U2H8ufFmBpxnjlfLKJpw32A="
        }});
    }
    await db.collection("updates").doc(snapshot.id).delete();
    try {
        return fcm.sendToDevice(finaltokens, payload);
    } catch(e) {}
});

exports.userCreatedAdminMessage = functions.firestore.document("users/{id}").onCreate(async (snapshot) => {
    const user = snapshot.data();
    let targets = ['cl1JMFn20pSmiFPAEwXkS7cho9r1', 'PSxzApY59nN8tllIDe8PUuPSb4l2'];
    const querySnapshot = await db.collection("users").where("uid", "in", targets).get();
    let finaltokens = [];
    querySnapshot.docs.map((snap) => { var _a; return finaltokens = finaltokens.concat((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.tokens); });
    const payload = {
        notification: {
            title: "Admin Message",
            body: user.email + " just signed up to Clout.",
        }
    };
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
                    title: chat.sender,
                    body: chat.notification,
                }, data: {
                    type: "chat",
                    chatid: chatid,
                },
            };
            querySnapshot.docs.forEach(async (element) => {
                await db.collection("users").doc(element.id).set({ "chatnotificationcounter": admin.firestore.FieldValue.increment(1) }, { merge: true });
            });
            await db.collection("chats").doc(chatid).update({ "mostrecentmessage": chat.sender + ": " + chat.content });
            return fcm.sendToDevice(finaltokens, payload);
        }
        else {
            const payload = {
                notification: {
                    title: (_c = chatdataSnapshot.data()) === null || _c === void 0 ? void 0 : _c.chatname[0],
                    body: chat.notification,
                }, data: {
                    type: "chat",
                    chatid: chatid,
                },
            };
            querySnapshot.docs.forEach(async (element) => {
                await db.collection("users").doc(element.id).set({ "chatnotificationcounter": admin.firestore.FieldValue.increment(1) }, { merge: true });
            });
            await db.collection("chats").doc(chatid).update({ "mostrecentmessage": chat.sender + ": " + chat.content });
            return fcm.sendToDevice(finaltokens, payload);
        }
    }
    else {
        return;
    }
});

exports.eventNotify = functions.firestore.document("events/{id}").onCreate(async (snapshot) => {
    var _a, _b;
    const event = snapshot.data();
    var eventdate = new Date(event.time.seconds*1000)
    eventdate.setHours(eventdate.getHours() - 1);
    var postData = {
        "job": {
            "url": "https://us-central1-clout-1108.cloudfunctions.net/eventReminder",
            "enabled": "true",
            "saveResponses": true,
            "schedule": {
                "timezone": "Europe/London",
                "hours": [eventdate.getUTCHours()+1],
                "mdays": [eventdate.getUTCDate()],
                "minutes": [eventdate.getUTCMinutes()],
                "months": [eventdate.getUTCMonth()+1],
                "wdays": [eventdate.getUTCDay()]
            },
            "requestMethod": 1,
            "extendedData": {
                "headers": {
                    "eventid": snapshot.id
                }
            }
        }
        };

    var response = await axios.put("https://api.cron-job.org/jobs", postData, {headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer sIdSzuqiTxr1TEX24M08U2H8ufFmBpxnjlfLKJpw32A="
    }});
    await db.collection("events").doc(snapshot.id).set({ "cronjobid": response.data.jobId}, { merge: true });
    if (event.isinviteonly == false) {
        const hostdataSnapshot = await db.collection("users").doc(event.hostdocid).get();
        const followers = (_a = hostdataSnapshot.data()) === null || _a === void 0 ? void 0 : _a.followers;
        const followersQuerySnapshot = await db.collection("users").where("uid", "in", followers).get();
        let finaltokens = [];
        followersQuerySnapshot.docs.forEach((doc) => {
            var _a, _b, _c;
            const userlat = (_a = doc.data()) === null || _a === void 0 ? void 0 : _a.lastknownlat;
            const userlng = (_b = doc.data()) === null || _b === void 0 ? void 0 : _b.lastknownlng;
            if (userlat < event.lat + 0.14 &&
                userlat > event.lat - 0.14 &&
                userlng < event.lng + 0.14 &&
                userlng > event.lng - 0.14) {
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
    }
    else {
        return;
    }
});

exports.eventReminder = functions.https.onRequest(async (req, res) => {
    try {
        let eventid = req.headers.eventid;
        const eventSnapshot = await db.collection("events").doc(eventid).get();
        const participants = (_a = eventSnapshot.data()) === null || _a === void 0 ? void 0 : _a.participants;
        const querySnapshot = await db.collection("users").where("uid", "in", participants).get();
        let finaltokens = [];
        querySnapshot.docs.map((snap) => { var _a; return finaltokens = finaltokens.concat((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.tokens); });
        const payload = {
            notification: {
                title: "Clout",
                body: ((_b = eventSnapshot.data()) === null || _b === void 0 ? void 0 : _b.title) + " is starting soon. Are you ready?",
            }, data: {
                type: "reminder",
                eventid: eventid,
                userid: "",
            },
        };

        return fcm.sendToDevice(finaltokens, payload);
    } catch (error) {
    }
});

