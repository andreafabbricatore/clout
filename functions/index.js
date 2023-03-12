const functions = require("firebase-functions");
const admin = require("firebase-admin");
const firebase_admin_1 = require("firebase-admin");
const stripe = require("stripe")("sk_test_51Ma5kMGYXn1BIYJpdAf4bo1FEeviwctQ7Agu0UosbdlfrIsWDrHdYqIXRnsvAp1zefxIJ6ImyEKorgj9yWcyGefx00noI1sq26")

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
            if (userlat < event.lat + 0.06 &&
                userlat > event.lat - 0.06 &&
                userlng < event.lng + 0.06 &&
                userlng > event.lng - 0.06) {
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

exports.stripePaymentIntentRequest = functions.https.onRequest(async (req, res) => {
    try {
        let customerId;

        //Gets the customer who's email id matches the one sent by the client
        const customerList = await stripe.customers.list({
            email: req.body.email,
            limit: 1
        });
                
        //Checks the if the customer exists, if not creates a new customer
        if (customerList.data.length !== 0) {
            customerId = customerList.data[0].id;
        }
        else {
            const customer = await stripe.customers.create({
                email: req.body.email,
                name: req.body.name,
                description: "Clout UID: " + req.body.uid
            });
            customerId = customer.data.id;
        }

        //Creates a temporary secret key linked with the customer 
        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customerId },
            { apiVersion: '2020-08-27' }
        );

        //Creates a new payment intent with amount passed in from the client
        const paymentIntent = await stripe.paymentIntents.create({
            amount: parseInt(req.body.amount),
            currency: 'eur',
            customer: customerId,
        })

        res.status(200).send({
            paymentIntent: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            success: true,
        })
        
    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
});

exports.stripeAccount = functions.https.onRequest(async (req, res) => {
    const { method } = req
    if (method === "GET") {
      // CREATE CONNECTED ACCOUNT
      const { mobile } = req.query
      const account = await stripe.accounts.create({
        country: 'IT',
        type: 'express',
        capabilities: {card_payments: {requested: true}, transfers: {requested: true}},
        business_type: 'individual',
      })
      const accountLinks = await stripe.accountLinks.create({
        account: account.id,
        refresh_url: `https://outwithclout.com`,
        return_url: `https://outwithclout.page.link/NcxQ`,
        type: "account_onboarding",
      })
      if (mobile) {
        // In case of request generated from the flutter app, return a json response
        res.status(200).json({ success: true, url: accountLinks.url })
      } else {
        // In case of request generated from the web app, redirect
        res.redirect(accountLinks.url)
      }
    } else if (method === "DELETE") {
      // Delete the Connected Account having provided ID
      const {
        query: { id },
      } = req
      console.log(id)
      const deleted = await stripe.accounts.del(id)
      res.status(200).json({ message: "account deleted successfully", deleted })
    } else if (method === "POST") {
      // Retrieve the Connected Account for the provided ID
      // I know it shouldn't be a POST call. Don't judge :D I had a lot on my plate
      const account = await stripe.accounts.retrieve(req.query.id)
      res.status(200).json({ account })
    }
  });
