package main

import (
	"context"
	"fmt"
	"log"
	"tdee-server/internal/awcta"
	"time"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/iterator"
)

var projectID = "tdee-adaptive-app"

// shouldProcess determines if a user is eligible for a new target calculation.
// (For now, we process everyone. This is a stub for future logic, e.g., checking for pauses).
func shouldProcess(user awcta.User) bool {
	// Example future logic:
	// if user.BreakUntilYMD > 0 { return false }
	return true
}

func main() {
	ctx := context.Background()
	conf := &firebase.Config{ProjectID: projectID}
	app, err := firebase.NewApp(ctx, conf)
	if err != nil {
		log.Fatalf("error initializing app: %v\n", err)
	}
	client, err := app.Firestore(ctx)
	if err != nil {
		log.Fatalf("error initializing firestore: %v\n", err)
	}
	defer client.Close()

	log.Println("AWCTA Runner starting...")

	// 1. Acquire Singleton Lock
	lockRef := client.Collection("runner_lock").Doc("lock")
	err = client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		doc, err := tx.Get(lockRef)
		if err != nil && doc == nil { // Lock doesn't exist, create it.
			return tx.Set(lockRef, map[string]interface{}{"locked_at": time.Now().UTC()})
		}
		if doc.Exists() {
			lockedAt, ok := doc.Data()["locked_at"].(time.Time)
			if ok && time.Since(lockedAt) < 10*time.Minute {
				return fmt.Errorf("runner is already locked")
			}
		}
		// Overwrite old lock
		return tx.Set(lockRef, map[string]interface{}{"locked_at": time.Now().UTC()})
	})

	if err != nil {
		log.Fatalf("Failed to acquire lock: %v", err)
	}
	log.Println("Lock acquired successfully.")

	// 2. Process Users
	iter := client.Collection("users").Documents(ctx)
	processedCount := 0
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Printf("Failed to iterate users: %v", err)
			break // Exit loop on iterator error
		}

		var u awcta.User
		if err := doc.DataTo(&u); err != nil {
			log.Printf("Failed to parse user %s: %v", doc.Ref.ID, err)
			continue
		}

		if !shouldProcess(u) {
			continue
		}

		// Perform the core calculation
		audit := awcta.Compute(u)

		// Create a new audit document and update the user document in a single transaction
		err = client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
			// Create new audit record
			auditRef := client.Collection("weekly_audits").NewDoc()
			if err := tx.Create(auditRef, audit); err != nil {
				return err
			}

			// Update user document
			userRef := client.Collection("users").Doc(u.UID)
			return tx.Update(userRef, []firestore.Update{
				{Path: "e_t_kcal", Value: audit.ETAfterKcal},
				{Path: "next_target_kcal", Value: audit.TargetProposedKcal},
				{Path: "approved", Value: false},
				{Path: "weeks_tier", Value: firestore.Increment(1)},
			})
		})

		if err != nil {
			log.Printf("Failed to process user %s: %v", u.UID, err)
		} else {
			processedCount++
		}
	}

	// 3. Release Lock
	if _, err := lockRef.Delete(ctx); err != nil {
		log.Printf("Warning: Failed to release lock: %v", err)
	} else {
		log.Println("Lock released.")
	}

	log.Printf("AWCTA Runner finished. Processed %d users.", processedCount)
}
