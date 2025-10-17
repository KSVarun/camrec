#!/bin/bash
umask 007

LOG_FILE="/var/log/pi_status_logger/service.log"
exec >> "$LOG_FILE" 2>&1

LOG_DIR="/home/idks/develop/bash/camrec/logs"
INTERVAL=10             # seconds between measurements
ROTATE_INTERVAL=120     # rotate every 2 minutes (120 seconds)
mkdir -p "$LOG_DIR"

echo "Logging system metrics every $INTERVAL seconds."
echo "Log will rotate every $((ROTATE_INTERVAL/60)) minutes."
echo "Logs stored in: $LOG_DIR"
echo "Press Ctrl+C to stop."
echo

start_time=$(date +%s)

# Function to create a new log file with header
create_new_log() {
  current_time=$(date +"%Y%m%d_%H%M%S")
  LOG_FILE="$LOG_DIR/pi_status_$current_time.csv"
  echo "timestamp,cpu_temp,cpu_usage_percent,ram_used_mb,ram_total_mb,ram_percent,core_voltage,throttled_flags" > "$LOG_FILE"
  echo "Created new log file: $LOG_FILE"
}

create_new_log

while true; do
  now=$(date +%s)
  elapsed=$((now - start_time))

  # Rotate log file every 2 minutes
  if (( elapsed >= ROTATE_INTERVAL )); then
    create_new_log
    start_time=$now
  fi

  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  # --- CPU Temperature ---
  if command -v vcgencmd &> /dev/null; then
    cpu_temp=$(vcgencmd measure_temp | cut -d"=" -f2 | tr -d "'C")
  else
    cpu_temp="N/A"
  fi

  # --- CPU Usage ---
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
  cpu_usage=$(printf "%.1f" "$cpu_usage")

  # --- RAM Usage ---
  ram_total=$(free -m | awk '/Mem:/ {print $2}')
  ram_used=$(free -m | awk '/Mem:/ {print $3}')
  ram_percent=$((ram_used * 100 / ram_total))

  # --- Voltage ---
  if command -v vcgencmd &> /dev/null; then
    voltage=$(vcgencmd measure_volts core | cut -d"=" -f2 | tr -d "V")
  else
    voltage="N/A"
  fi

  # --- Throttling ---
  if command -v vcgencmd &> /dev/null; then
    throttled=$(vcgencmd get_throttled | awk -F= '{print $2}')
  else
    throttled="N/A"
  fi

  # --- Append to current CSV ---
  echo "$timestamp,$cpu_temp,$cpu_usage,$ram_used,$ram_total,$ram_percent,$voltage,$throttled" >> "$LOG_FILE"

  sleep "$INTERVAL"
done
