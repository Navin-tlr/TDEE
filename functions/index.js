const {onUserCreate} = require("firebase-functions/v2/auth");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * This function triggers automatically whenever a new user account is created.
 */
exports.initializeNewUser = onUserCreate(async (event) => {
  const user = event.data;
  console.log("A new user signed up:", user.uid);

  const firestore = admin.firestore();
  const today = new Date();
  const year = today.getFullYear();
  const month = (today.getMonth() + 1).toString().padStart(2, "0");
  const day = today.getDate().toString().padStart(2, "0");
  const ymdString = `${year}${month}${day}`;
  const docId = `${user.uid}_${ymdString}`;

  const initialData = {
    uid: user.uid,
    ymd: parseInt(ymdString),
    kcal: 0,
    p_g: 0,
    c_g: 0,
    f_g: 0,
  };

  try {
    await firestore.collection("food_daily").doc(docId).set(initialData);
    console.log("Successfully created initial document for user:", user.uid);
  } catch (error) {
    console.error(
        "Error creating initial document for user:",
        user.uid,
        error,
    );
  }
});
