#!/bin/bash

APP_NAME="agent-app"
PORT="15034"
LOG_FILE="/var/log/agent-app/monitor.log"

DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "====== SYSTEM MONITOR RESULT ======"
echo "[HEALTH CHECK]"

# =========================
# Process Check
# =========================
PID=$(pgrep -f "$APP_NAME" | head -n 1)

if [ -z "$PID" ]; then
    echo "Checking process '$APP_NAME'... [FAIL]"
    echo "[ERROR] Process not running"
    exit 1
else
    echo "Checking process '$APP_NAME'... [OK] (PID: $PID)"
fi

# =========================
# Port Check
# =========================
if ss -tuln | grep -q ":$PORT "; then
    echo "Checking port $PORT... [OK]"
else
    echo "Checking port $PORT... [FAIL]"
    echo "[ERROR] Port $PORT is not listening"
    exit 1
fi

# =========================
# Firewall Check
# =========================
echo "[FIREWALL CHECK]"

if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(ufw status | head -n 1)

    if echo "$UFW_STATUS" | grep -q "active"; then
        echo "UFW Status... [OK]"
    else
        echo "UFW Status... [WARNING] Firewall inactive"
    fi
else
    echo "UFW not installed... [WARNING]"
fi

# =========================
# Resource Monitoring
# =========================
echo "[RESOURCE MONITORING]"

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM_USAGE=$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "CPU Usage : ${CPU_USAGE}%"
echo "MEM Usage : ${MEM_USAGE}%"
echo "DISK Used : ${DISK_USAGE}%"

# =========================
# Threshold Warning
# =========================
CPU_INT=${CPU_USAGE%.*}
MEM_INT=${MEM_USAGE%.*}

if [ "$CPU_INT" -gt 20 ]; then
    echo "[WARNING] CPU threshold exceeded (${CPU_USAGE}% > 20%)"
fi

if [ "$MEM_INT" -gt 10 ]; then
    echo "[WARNING] MEM threshold exceeded (${MEM_USAGE}% > 10%)"
fi

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "[WARNING] DISK threshold exceeded (${DISK_USAGE}% > 80%)"
fi

# =========================
# Log Append
# =========================
echo "[$DATE] PID:$PID CPU:${CPU_USAGE}% MEM:${MEM_USAGE}% DISK_USED:${DISK_USAGE}%" >> "$LOG_FILE"

echo "[INFO] Log appended: $LOG_FILE"

# =========================
# Log Rotation
# =========================
if [ -f "$LOG_FILE" ]; then
    FILE_SIZE_MB=$(du -m "$LOG_FILE" | cut -f1)

    if [ "$FILE_SIZE_MB" -ge 10 ]; then
        TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
        mv "$LOG_FILE" "/var/log/agent-app/monitor_${TIMESTAMP}.log"
        touch "$LOG_FILE"

        ls -tp /var/log/agent-app/monitor_*.log 2>/dev/null | tail -n +11 | xargs -r rm --

        echo "[INFO] Log rotated"
    fi
fi
