package main

import (
        "encoding/csv"
        "encoding/json"
        "log"
        "net/http"
        "os"
        "path/filepath"
        "sort"
)

type Stat struct {
        Timestamp      string `json:"timestamp"`
        CpuTemp        string `json:"cpu_temp"`
        CpuUsage       string `json:"cpu_usage_percent"`
        RamPercent     string `json:"ram_percent"`
        CoreVoltage    string `json:"core_voltage"`
        ThrottledFlags string `json:"throttled_flags"`
}

func readLatestStats(dir string, maxFiles int) ([]Stat, error) {
        log.Println("[DEBUG] Scanning directory:", dir)

        files, err := filepath.Glob(filepath.Join(dir, "*.csv"))
        if err != nil {
                log.Println("[ERROR] Glob failed:", err)
                return nil, err
        }

        log.Printf("[DEBUG] Found %d csv files\n", len(files))

        if len(files) == 0 {
                log.Println("[WARN] No CSV files found")
                return []Stat{}, nil
        }

        sort.Strings(files)

        if len(files) > maxFiles {
                files = files[len(files)-maxFiles:]
        }

        var all []Stat

        for _, file := range files {
                log.Println("[DEBUG] Reading file:", file)

                f, err := os.Open(file)
                if err != nil {
                        log.Println("[ERROR] Cannot open file:", err)
                        continue
                }

                r := csv.NewReader(f)
                records, err := r.ReadAll()
                f.Close()

                if err != nil {
                        log.Println("[ERROR] CSV parse failed:", err)
                        continue
                }

                if len(records) < 2 {
                        log.Println("[WARN] CSV has no data rows:", file)
                        continue
                }

                headers := records[0]
                log.Println("[DEBUG] CSV headers:", headers)

                for rowIdx, row := range records[1:] {
                        if len(row) != len(headers) {
                                log.Printf("[WARN] Row length mismatch in %s at row %d\n", file, rowIdx+2)
                                continue
                        }

                        m := map[string]string{}
                        for i, h := range headers {
                                m[h] = row[i]
                        }

                        stat := Stat{
                                Timestamp:      m["timestamp"],
                                CpuTemp:        m["cpu_temp"],
                                CpuUsage:       m["cpu_usage_percent"],
                                RamPercent:     m["ram_percent"],
                                CoreVoltage:    m["core_voltage"],
                                ThrottledFlags: m["throttled_flags"],
                        }

                        if stat.Timestamp == "" {
                                log.Println("[WARN] Empty timestamp row skipped")
                                continue
                        }

                        all = append(all, stat)
                }
        }

        log.Printf("[DEBUG] Total parsed stats: %d\n", len(all))
        return all, nil
}

func main() {
        log.Println("[INFO] Starting Pi Dashboard")

        http.Handle("/", http.FileServer(http.Dir("./public")))

        http.HandleFunc("/api/stats", func(w http.ResponseWriter, r *http.Request) {
                log.Println("[INFO] /api/stats requested")

                stats, err := readLatestStats("/home/idks/develop/bash/camrec/logs",10)
                if err != nil {
                        log.Println("[ERROR] readLatestStats failed:", err)
                        http.Error(w, err.Error(), 500)
                        return
                }

                w.Header().Set("Content-Type", "application/json")
                json.NewEncoder(w).Encode(stats)
        })

        log.Println("[INFO] Listening on :8080")
        log.Fatal(http.ListenAndServe(":8080", nil))
}
