package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net/http"
	"sync/atomic"
	"time"
)

var failureMode int32 = 0

// Send logs to OpenSearch
func sendToOpenSearch(data map[string]interface{}) {
	data["@timestamp"] = time.Now().Format(time.RFC3339)
	jsonData, err := json.Marshal(data)
	if err != nil {
		log.Printf("Error marshaling log data: %v", err)
		return
	}
	resp, error := http.Post(
		// send data to OpenSearch index "logs-demo"
		"http://localhost:9200/logs-demo/_doc",
		"application/json",
		bytes.NewBuffer(jsonData),
	)
	if error != nil {
		log.Printf("Failed to send to OpenSearch: %v", error)
		return
	}

	defer resp.Body.Close()
}

// Dependency simulator
func callPaymentService() (string, int, string) {
	retries := 0

	if atomic.LoadInt32(&failureMode) == 1 {
		// 50% failure rate
		if rand.Intn(2) == 0 {
			for retries < 2 {
				time.Sleep(100 * time.Millisecond)
				retries++
			}
			return "dependency_payment_service_down", retries, "payment-service"
		}
	}

	time.Sleep(50 * time.Millisecond)
	return "", retries, ""
}

// Helper to determine status based on error type
func getStatus(errorType string) string {
	if errorType != "" {
		return "error"
	}
	return "success"
}

// Toggle failure mode for testing
func toggleFailuremode(w http.ResponseWriter, r *http.Request) {
	newval := atomic.LoadInt32(&failureMode) ^ 1
	atomic.StoreInt32(&failureMode, newval)

	msg := fmt.Sprintf("failureMode=%v\n", newval == 1)

	sendToOpenSearch(map[string]interface{}{
		"service": "checkout",
		"event":   "toggle_failure",
		"enabled": newval == 1,
	})

	w.Write([]byte(msg))
}

// Health Check Handler
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK"))
}

// Checkout Handler
func checkoutHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()

	// Simulate 50% error rate in payment service with retries
	errorType, retries, dependency := callPaymentService()

	latency := time.Since(start).Milliseconds()

	// Structure log data
	data := map[string]interface{}{
		"service":     "checkout",
		"endpoint":    "/checkout",
		"region":      "eu-west-1",
		"latency_ms":  latency,
		"retry_count": retries,
		"status":      getStatus(errorType),
	}

	if errorType != "" {
		data["error_type"] = errorType
		data["dependency"] = dependency
	}

	sendToOpenSearch(data)

	if errorType != "" {
		http.Error(w, "dependency failure", http.StatusServiceUnavailable)
		return
	}

	w.Write([]byte("checkout success"))
}

func main() {
	http.HandleFunc("/checkout", checkoutHandler)
	http.HandleFunc("/toggle-failure", toggleFailuremode)
	http.HandleFunc("/health", healthHandler)

	http.HandleFunc("/alert", func(w http.ResponseWriter, r *http.Request) {
		log.Println("🚨 ALERT RECEIVED")

		body, _ := io.ReadAll(r.Body)
		log.Println(string(body))

		w.WriteHeader(http.StatusOK)
	})

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
