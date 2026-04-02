package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"sync/atomic"
	"time"
)

var failureMode int32 = 0

// Structured logger
func logJson(data map[string]interface{}) {
	data["@timestamp"] = time.Now().Format(time.RFC3339)
	bytes, err := json.Marshal(data)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(bytes))
}

// Send logs to OpenSearch
func sendToOpenSearch(data map[string]interface{}) {
	data["@timestamp"] = time.Now().Format(time.RFC3339)
	jsonData, err := json.Marshal(data)
	if err != nil {
		log.Printf("Error marshaling log data: %v", err)
		return
	}
	resp, error := http.Post(
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
func callExternalService() (string, int) {
	retries := 0

	if atomic.LoadInt32(&failureMode) == 1 {
		// simulate retries and delay
		for retries < 2 {
			time.Sleep(1 * time.Second)
			retries++
		}
		return "Service Unavailable", retries
	}
	time.Sleep(50 * time.Millisecond)
	return "", retries
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

	logJson(map[string]interface{}{
		"service": "checkout",
		"event":   "toggle_failure",
		"enabled": newval == 1,
	})

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

	errorType, retries := callExternalService()

	latency := time.Since(start).Milliseconds()

	data := map[string]interface{}{
		"service":     "checkout",
		"endpoint":    "/checkout",
		"latency_ms":  latency,
		"error":       errorType,
		"retry_count": retries,
		"status":      getStatus(errorType),
	}

	logJson(data)
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
