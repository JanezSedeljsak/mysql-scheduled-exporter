package main

import (
    "bytes"
    "net/http"
    "os/exec"
    "strings"
)

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
    cmdCronService := exec.Command("pgrep", "crond")
    if err := cmdCronService.Run(); err != nil {
        http.Error(w, "Cron service is not running", http.StatusInternalServerError)
        return
    }

    cmdCrontab := exec.Command("crontab", "-l")
    var crontabOut bytes.Buffer
    cmdCrontab.Stdout = &crontabOut
    if err := cmdCrontab.Run(); err != nil {
        http.Error(w, "Failed to list crontab jobs", http.StatusInternalServerError)
        return
    }
    
    if !strings.Contains(crontabOut.String(), "/exporter/export.sh") {
        http.Error(w, "/exporter/export.sh not scheduled in crontab", http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusOK)
    w.Write([]byte("OK"))
}

func main() {
    http.HandleFunc("/health", healthCheckHandler)
    http.ListenAndServe(":80", nil)
}