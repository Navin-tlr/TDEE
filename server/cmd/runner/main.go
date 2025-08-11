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

var firestoreClient *firestore.Client
var firebaseAuth *auth.Client
var projectID = "tdee-adaptive-app" // Your Firebase Project ID

// corsMiddleware wraps an HTTP handler to add CORS headers.
func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*") // Allow any origin
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	}
}

func main() {
	ctx := context.Background()
	conf := &firebase.Config{ProjectID: projectID}
	app, err := firebase.NewApp(ctx, conf)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}
	firestoreClient, err = app.Firestore(ctx)
	if err != nil {
		log.Fatalf("error initializing firestore: %v\n", err)
	}
	firebaseAuth, err = app.Auth(ctx)
	if err != nil {
		log.Fatalf("error initializing auth: %v\n", err)
	}
	log.Println("Firebase Admin SDK initialized successfully")

	// Wrap our handler with the CORS middleware
	http.HandleFunc("/initialize-user", corsMiddleware(initializeUserHandler))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Starting server on port %s", port)
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
	if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
		http.Error(w, "Authorization header must be Bearer token", http.StatusUnauthorized)
		return
	}
	idToken := strings.TrimPrefix(authHeader, "Bearer ")
	token, err := firebaseAuth.VerifyIDToken(context.Background(), idToken)
	if err != nil {
		log.Printf("Error verifying ID token: %v", err)
		http.Error(w, "Invalid auth token", http.StatusUnauthorized)
		return
	}
	uid := token.UID
	today := time.Now()
	year, month, day := today.Date()
	ymdString := fmt.Sprintf("%d%02d%02d", year, month, day)
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
		log.Printf("Error creating firestore document: %v", err)
		http.Error(w, "Failed to create user document", http.StatusInternalServerError)
		return
	}
	log.Printf("Successfully created initial document for user: %s", uid)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "success"})
}

func mustAtoi(s string) int {
	i, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}
	return i
}
