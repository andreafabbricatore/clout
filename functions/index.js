const functions = require("firebase-functions");
const admin = require("firebase-admin");
const firebase_admin_1 = require("firebase-admin");
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
                    title: chat.sender,
                    body: chat.notification,
                }, data: {
                    type: "chat",
                    chatid: chatid,
                },
            };
            querySnapshot.docs.forEach(async (element) => {
                await db.collection("users").doc(element.id).set({ "chatnotificationcounter": firebase_admin_1.firestore.FieldValue.increment(1) }, { merge: true });
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
                await db.collection("users").doc(element.id).set({ "chatnotificationcounter": firebase_admin_1.firestore.FieldValue.increment(1) }, { merge: true });
            });
            await db.collection("chats").doc(chatid).update({ "mostrecentmessage": chat.sender + ": " + chat.content });
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
    if (event.isinviteonly == false) {
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
    }
    else {
        return;
    }
});

const calculateOrderAmount = (items) => {
    var prices = [];
    var catalog = [
        { 'id': '0', 'price': 2.99 },
        { 'id': '1', 'price': 3.99 },
        { 'id': '2', 'price': 4.99 },
        { 'id': '3', 'price': 5.99 },
        { 'id': '4', 'price': 6.99 },
    ];

    items.forEach((item) => {
        price = catalog.find(x => x.id = item.id).price;
        prices.push(price);
    });

    return parseInt(prices.reduce((a, b) => a + b) * 100);
}

const generateResponse = function(intent) {
    switch (intent.status) {
        case 'requires_action':
            return {
                clientSecret: intent.clientSecret,
                requiresAction: true,
                status: intent.status
            };
        case 'requires_payment_method':
            return {
                'error': 'Your card was denied, please provide a new payment method',
            };
        case 'succeeded':
            console.log('Payment succeeded.');
            return {clientSecret: intent.clientSecret, status: intent.status};
    }
}

exports.StripePayEndpointMethodId = functions.https.onRequest(async (req, res) => {
    const { paymentMethodId, items, currency, useStripeSdk, } = req.body;
    const orderAmount = calculateOrderAmount;
  
    try {
      if (paymentMethodId) {
        // Create a new payment intent
        const params = {
          amount: orderAmount,
          confirm: true,
          confirmation_method: 'manual',
          currency, 
          payment_method: paymentMethodId,
          use_stripe_sdk: useStripeSdk
        }
        const intent = await stripe.paymentIntents.create(params);
        console.log(intent);
        return res.send(generateResponse(intent))
      }
      return res.sendStatus(400);
    } catch(e) {
        return res.send({ error: e.message });
    }
  
  
  });

exports.StripePayEndpointIntentId = functions.https.onRequest(async (req, res) => {
    const { paymentIntentId} = req.body;
    try {
        if (paymentIntentId) {
            const intent = await stripe.paymentIntents.confirm(paymentIntentId);
            return res.send(generateResponse(intent));
        }
        return res.sendStatus(400);
    } catch(e) {
        return res.send({ error: e.message });
    }
  });
