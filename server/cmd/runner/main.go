package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
)

// Global clients that will be initialized once.
var (
	firestoreClient *firestore.Client
	firebaseAuth    *auth.Client
)

// init runs before main and is the idiomatic place for initialization.
func init() {
	ctx := context.Background()

	// firebase.NewApp with a nil config will automatically use the
	// service account associated with the Cloud Run instance.
	// This is the most reliable method.
	app, err := firebase.NewApp(ctx, nil)
	if err != nil {
		log.Fatalf("FATAL: error initializing Firebase app: %v\n", err)
	}

	// Get the Firestore client from the initialized app.
	firestoreClient, err = app.Firestore(ctx)
	if err != nil {
		log.Fatalf("FATAL: error initializing Firestore client: %v\n", err)
	}

	// Get the Auth client from the initialized app.
	firebaseAuth, err = app.Auth(ctx)
	if err != nil {
		log.Fatalf("FATAL: error initializing Auth client: %v\n", err)
	}

	log.Println("Firebase Admin SDK initialized successfully.")
}

func main() {
	// Set up the HTTP handlers.
	http.HandleFunc("/initialize-user", corsMiddleware(initializeUserHandler))

	// Determine the port to listen on.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("Defaulting to port %s", port)
	}

	log.Printf("Listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func initializeUserHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Only POST method is allowed", http.StatusMethodNotAllowed)
		return
	}

	authHeader := r.Header.Get("Authorization")
	if !strings.HasPrefix(authHeader, "Bearer ") {
		log.Println("ERROR: Authorization header missing or malformed.")
		http.Error(w, "Authorization header must be a Bearer token", http.StatusUnauthorized)
		return
	}

	idToken := strings.TrimPrefix(authHeader, "Bearer ")
	token, err := firebaseAuth.VerifyIDToken(context.Background(), idToken)
	if err != nil {
		// This is where the error is happening. Log the specific error from the SDK.
		log.Printf("ERROR: Failed to verify ID token: %v", err)
		http.Error(w, "Invalid auth token", http.StatusUnauthorized)
		return
	}

	uid := token.UID
	log.Printf("Token verified successfully for UID: %s", uid)

	today := time.Now()
	ymdString := today.Format("20060102") // More robust date formatting
	docID := fmt.Sprintf("%s_%s", uid, ymdString)

	initialData := map[string]interface{}{
		"uid":  uid,
		"ymd":  mustAtoi(ymdString),
		"kcal": 0,
		"p_g":  0,
		"c_g":  0,
		"f_g":  0,
	}

	_, err = firestoreClient.Collection("food_daily").Doc(docID).Set(context.Background(), initialData)
	if err != nil {
		log.Printf("ERROR: Failed to create firestore document for UID %s: %v", uid, err)
		http.Error(w, "Failed to create user document", http.StatusInternalServerError)
		return
	}

	log.Printf("Successfully created initial document for user: %s", uid)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "success", "uid": uid})
}

// corsMiddleware remains the same.
func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	}
}

// mustAtoi remains the same.
func mustAtoi(s string) int {
	i, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}
	return i
}
