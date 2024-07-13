package main

import (
    "net/http"
    "os/exec"
)

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
    cmd := exec.Command("pgrep", "crond")
    if err := cmd.Run(); err != nil {
        http.Error(w, "Cron service is not running", http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusOK)
    w.Write([]byte("OK"))
}

func main() {
    http.HandleFunc("/health", healthCheckHandler)
    http.ListenAndServe(":80", nil)
}