const functions = require("firebase-functions");
const {getFirestore, FieldPath, Timestamp} =
    require("firebase-admin/firestore");
const admin = require("firebase-admin");


const serviceAccount = require(
    "./jawsandteeth-app-firebase-adminsdk-sbntk-bf9a53ec3b.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL:
    "https://jawsandteeth-app-default-rtdb.asia-southeast1.firebasedatabase.app",
});

//  initializeApp();
const db = getFirestore();
// db.useEmulator("127.0.0.1", 8080);
// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});
exports.sendByeEmail = functions.auth.user().onDelete((user) => {
  // ...
  functions.logger.info("Hello Deleted User!", {structuredData: true});
});

exports.getPatientAppointments = functions.runWith({
  enforceAppCheck: false,
}).https.onCall(async (data, context) => {
  let response="{}";
  try {
    const currentTimestamp = Timestamp.fromDate(new Date());
    response="{\"patientAppointments\":[";
    await db.collection("appointments")
        .where("clientUser", "==", data.userid)
        .where("where", "==", data.clinicid)
        .where("when", ">=", currentTimestamp)
        .get().then((snapshot) => {
          if (!snapshot.empty) {
            snapshot.forEach((doc) => {
              response += JSON.stringify(doc.data());
              response +=",";
            });
            response = response.slice(0, -1);
          } else {
            console.log("empty result");
          }
          response += "]}";
        },
        );
  } catch (e) {
    console.log(e);
  }
  return response;
});
exports.searchPatients = functions.runWith({
  enforceAppCheck: false,
}).https.onCall(async (data, context) => {
  let response="{}";
  console.log(isNaN(data));
  try {
    // console.log(data);
    const fieldChoice = isNaN(data)?"name":"phoneNumber";
    await db.collection("users")
        .where(fieldChoice, ">=", data)
        .where(fieldChoice, "<=", data + "\uf8ff")
        .get()
        .then((result) => {
          // console.log(result.empty);
          if (!result.empty) {
            response = "{\"patientList\":[";
            result.forEach((doc) => {
              response += "{\"name\":";
              response += JSON.stringify(doc.data().name);
              response += ",\"email\":";
              response += JSON.stringify(doc.data().email);
              response += ",\"phone\":";
              response += JSON.stringify(doc.data().phoneNumber);
              response += ",\"gender\":";
              response += JSON.stringify(doc.data().gender);
              response += ",\"age\":";
              response += JSON.stringify(doc.data().age);

              response += ",\"reverseLookup\":";
              response += JSON.stringify(doc.id);

              response += "},";
              // console.log(doc);
            });
            response = response.slice(0, -1);
            response += "]}";
          }
        });
  } catch (e) {
    console.log(e);
  }
  console.log(response);
  return response;
});
exports.createAppointment = functions.runWith({
  enforceAppCheck: false,
}).https.onCall(async (data, context) => {
  // if (context.app == undefined) {
  // throw new functions.https.HttpsError(
  // "failed-precondition",
  // "The function must be called from an App Check verified app.");
  // }
  try {
    const newdate= new Date(data.when);
    console.log(newdate);
    const firestoreTimestamp = Timestamp.fromDate(new Date(data.when));
    console.log(firestoreTimestamp);
    await db.collection("appointments").add({
      clientUser: data.user,
      when: newdate,
      where: data.clinic,
      status: "Confirmed",
    }).then((result) => {
      console.log("added appointment " + result);
    });
  } catch (e) {
    console.log(e);
  }
  return {};
});

exports.addPatientsUser = functions.runWith({
  enforceAppCheck: false,
}).https.onCall(async (data, context) => {
  // if (context.app == undefined) {
  // throw new functions.https.HttpsError(
  // "failed-precondition",
  // "The function must be called from an App Check verified app.");
  // }
  try {
    const jsonDataString = JSON.stringify(data);
    const jsonParsed = JSON.parse(jsonDataString);
    await db.collection("users").add({
      name: jsonParsed.name,
      email: jsonParsed.email,
      phoneNumber: jsonParsed.phoneNumber,
      age: jsonParsed.age,
      gender: jsonParsed.gender,
    }).then((result) => {
      console.log("added user id " + result.id +
          " in patients userlist. to be added to clinic " +
          jsonParsed.associatedClinic);
      db.collection("clinics")
          .doc(jsonParsed.associatedClinic)
          .collection("associatedUsers")
          .doc(result.id)
          .set({})
          .then((result) =>{
            console.log("Associated user added");
            console.log(result);
          });
    });
  } catch (e) {
    console.log(e);
  }
  return {};
});
exports.getMyClinicData = functions.https.onCall(async (data, context) => {
});
exports.getMyClinics = functions.runWith({
  enforceAppCheck: false,
}).https.onCall(async (data, context) => {
  // ...
  // if (context.app == undefined) {
  // throw new functions.https.HttpsError(
  // 'failed-precondition',
  // 'The function must be called from an App Check verified app.')
  // }
  const uid = context.auth.uid;
  console.log(uid);
  let response = "{}";
  response = "{\"myAssociatedClinics\":[";
  const userDataDB = db.collection("users").doc(uid);
  const userDataValues = await userDataDB.get();
  if (!userDataValues.exists) {
    console.log("No such document!");
  } else {
    try {
      const associatedClinics = userDataValues.get("associatedClinics");
      const myClinics = db.collection("/clinics");
      await myClinics
          .where(FieldPath.documentId(), "in", associatedClinics)
          .get()
          .then((snapshots) => {
            snapshots.forEach((doc) => {
              response += "{\"docID\":";
              response += JSON.stringify(doc.id);
              response += ",\"name\":";
              response += JSON.stringify(doc.data().name);
              response += "},";
            });
          });
      response = response.slice(0, -1);
    } catch (e) {
      //
      console.log("exception" + e);
    }
  }
  response += "]}";
  return response;
});
