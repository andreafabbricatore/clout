const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require('axios')
const stripe = require("stripe")(functions.config().stripe.testkey)
admin.initializeApp();
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
    let targets = ['cl1JMFn20pSmiFPAEwXkS7cho9r1', 'PSxzApY59nN8tllIDe8PUuPSb4l2', 'jR3G8sihlnXHt2nAEaB1sgI5Fog1'];
    const querySnapshot = await db.collection("users").where("uid", "in", targets).get();
    let finaltokens = [];
    querySnapshot.docs.map((snap) => { var _a; return finaltokens = finaltokens.concat((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.tokens); });
    const payload = {
        notification: {
            title: "Admin Message",
            body: user.email + " just signed up to Clout.",
        }
    };
    fcm.sendToDevice(finaltokens, payload);
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
            if (chat.type != "event") {
                await db.collection("chats").doc(chatid).update({ "mostrecentmessage": chat.sender + ": " + chat.content });
            } else {
                await db.collection("chats").doc(chatid).update({ "mostrecentmessage": chat.sender + ": " + "shared an event."});
            }
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
    
    }
});

exports.eventNotify = functions.firestore.document("events/{id}").onCreate(async (snapshot) => {
    var _a, _b;
    const event = snapshot.data();
    var eventdate = new Date(event.time.seconds*1000)
    eventdate.setHours(eventdate.getHours() - 1);
    var postData = {
        "job": {
            "url": "https://us-central1-clout-1108.cloudfunctions.net/eventCronJobUpdates",
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
        var friendsQuerySnapshot;
        var hostdataSnapshot;
        if (event.hostdocid == "jR3G8sihlnXHt2nAEaB1sgI5Fog1") {
            hostdataSnapshot = await db.collection("users").doc(event.hostdocid).get();
            friendsQuerySnapshot = await db.collection("users").where("plan", "!=", "business").get();
        } else {
            hostdataSnapshot = await db.collection("users").doc(event.hostdocid).get();
            const friends = (_a = hostdataSnapshot.data()) === null || _a === void 0 ? void 0 : _a.friends;
            friendsQuerySnapshot = await db.collection("users").where("uid", "in", friends).get();
        }
        let finaltokens = [];
        friendsQuerySnapshot.docs.forEach((doc) => {
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

exports.eventCronJobUpdates = functions.https.onRequest(async (req, res) => {
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
        const eventdata = eventSnapshot.data();
        if (eventdata['showlocation'] == false) {
            await db.collection("events").doc(eventid).update({'showlocation': true});
        };
        fcm.sendToDevice(finaltokens, payload);
        res.status(200).send();
    } catch (error) {
        res.status(404).send();
    }
});

exports.engagementNotis = functions.https.onRequest(async (req, res) => {
    try {
        const querySnapshot = await db.collection("users").where("lastusagetime", "<", Date.now()).get();
        let finaltokens = [];
        querySnapshot.docs.map((snap) => { var _a; return finaltokens = finaltokens.concat((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.tokens); });
        result = []
        querySnapshot.docs.forEach((element) => {
            result = result.concat(element.data()["username"])
        });
        res.status(200).send(result);
    } catch (error) {
        res.status(404).send("error");
    }
});

exports.forceEmailVerification = functions.firestore.document('/email_verification/{uid}').onCreate(async (snapshot, context) => {
    const uid = context.params.uid;
    admin.auth().updateUser(uid, {emailVerified: true});
    db.collection("email_verification").doc(snapshot.id).delete();
});

exports.forceallEmailVerifications = functions.firestore.document('/all_emails_verified/{id}').onCreate(async (snapshot, context) => {
    const querySnapshot = await db.collection("users").get();
    querySnapshot.docs.forEach((element) => {
        data = element.data()
        admin.auth().updateUser(data['uid'], {emailVerified: true});
    })
});

exports.checkIfPhoneExists = functions.https.onCall((data, context) => {
    const phone = data.phone
    return admin.auth().getUserByPhoneNumber(phone)
     .then(function(userRecord){
         return true;
     })
     .catch(function(error) {
         return false;
     });
 });

 exports.stripeAccount = functions.https.onRequest(async (req, res) => {
    const { method } = req
    
    // CREATE CONNECTED ACCOUNT
    if (method == "GET") {
        const { mobile } = req.query
        const account = await stripe.accounts.create({
            type: 'express',
        })
        const accountLinks = await stripe.accountLinks.create({
            account: account.id,
            refresh_url: 'https://us-central1-clout-1108.cloudfunctions.net/stripeAccount',
            return_url: 'https://outwithclout.com/',
            type: "account_onboarding",
        })
        if (mobile) {
            // In case of request generated from the flutter app, return a json response
            res.status(200).json({ success: true, url: accountLinks.url })
        } else {
            // In case of request generated from the web app, redirect
            res.redirect(accountLinks.url)
        }
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
            currency: req.body.currency,
            customer: customerId,
            automatic_payment_methods: {enabled: true},
            application_fee_amount: req.body.cloutfee,
            transfer_data: {
                destination: req.body.sellerstripebusinessid,
              },
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