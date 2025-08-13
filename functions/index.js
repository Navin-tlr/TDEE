const {onUserCreate} = require("firebase-functions/v2/auth");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * This function triggers automatically whenever a new user account is created.
 * It creates the essential starting documents for the user.
 */
exports.initializeNewUser = onUserCreate(async (event) => {
  const user = event.data;
  console.log("Initializing documents for new user:", user.uid);

  const firestore = admin.firestore();
  const today = new Date();
  const year = today.getFullYear();
  const month = (today.getMonth() + 1).toString().padStart(2, "0");
  const day = today.getDate().toString().padStart(2, "0");
  const ymdString = `${year}${month}${day}`;
  
  // Get a new write batch
  const batch = firestore.batch();

  // 1. Create the initial food_daily document
  const dailyDocId = `${user.uid}_${ymdString}`;
  const dailyDocRef = firestore.collection("food_daily").doc(dailyDocId);
  const initialDailyData = {
    uid: user.uid,
    ymd: parseInt(ymdString),
    kcal: 0, p_g: 0, c_g: 0, f_g: 0,
  };
  batch.set(dailyDocRef, initialDailyData);

  // 2. Create the initial user document (this is the missing piece)
  const userDocRef = firestore.collection("users").doc(user.uid);
  const initialUserData = {
    uid: user.uid,
    email: user.email,
    // Add other initial fields with null or default values
    height_cm: null,
    age_years: null,
    sex: null,
    approved: true, // Start as approved
  };
  batch.set(userDocRef, initialUserData);

  // Commit the batch
  try {
    await batch.commit();
    console.log("Successfully created initial documents for user:", user.uid);
  } catch (error) {
    console.error(
        "Error creating initial documents for user:",
        user.uid,
        error,
    );
  }
});