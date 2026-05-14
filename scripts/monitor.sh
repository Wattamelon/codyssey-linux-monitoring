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


# tail -n +11 이 이해가 안 되는 이유

현재 코드:

```bash
ls -tp /var/log/agent-app/monitor_*.log 2>/dev/null | tail -n +11 | xargs -r rm --
```

이 부분은:

```text
오래된 로그 파일 자동 삭제
```

를 위한 코드이다.

---

# 핵심 오해 포인트

많이 헷갈리는 부분이:

```text
"11번째 이후만 남긴다는 건가?"
```

처럼 느껴진다는 점이다.

하지만 실제로는 반대이다.

---

# 현재 코드 흐름

## 1단계

```bash
ls -tp /var/log/agent-app/monitor_*.log
```

실행.

---

# ls -tp 의미

## ls

파일 목록 출력.

---

## -t

최신 수정 시간 기준 정렬.

즉:

```text
최신 파일이 위쪽
```

으로 정렬된다.

---

## -p

디렉토리 구분용 / 추가.

현재는 큰 의미는 없음.

---

# 예시 출력

예를 들어 로그가:

```text
monitor_1.log
monitor_2.log
monitor_3.log
...
monitor_15.log
```

있다고 가정.

최신순 정렬되면:

```text
monitor_15.log
monitor_14.log
monitor_13.log
monitor_12.log
monitor_11.log
monitor_10.log
monitor_9.log
monitor_8.log
monitor_7.log
monitor_6.log
monitor_5.log
monitor_4.log
monitor_3.log
monitor_2.log
monitor_1.log
```

상태.

---

# 2단계

```bash
tail -n +11
```

실행.

---

# tail -n +11 의미

이건:

```text
11번째 줄부터 끝까지 출력
```

의미이다.

즉:

```text
앞의 10개는 제외
```

하고:

```text
11번째 이후만 선택
```

하는 것.

---

# 실제 결과

현재 목록에서:

```text
monitor_15.log
monitor_14.log
monitor_13.log
monitor_12.log
monitor_11.log
monitor_10.log
monitor_9.log
monitor_8.log
monitor_7.log
monitor_6.log
```

까지가 최신 10개.

tail -n +11 이후 결과:

```text
monitor_5.log
monitor_4.log
monitor_3.log
monitor_2.log
monitor_1.log
```

만 남는다.

즉:

```text
오래된 로그만 선택
```

되는 것.

---

# 3단계

```bash
xargs -r rm --
```

실행.

---

# 의미

선택된:

```text
오래된 로그들 삭제
```

.

즉 결과적으로:

```text
최신 10개 로그만 유지
```

하게 된다.

---

# 핵심 개념

현재 코드는:

```text
11번째 이후 로그를 "남기는 코드"
```

가 아니라,

```text
11번째 이후 로그를 "삭제 대상으로 선택하는 코드"
```

이다.

---

# 현재 구조 흐름

```text
로그 파일 최신순 정렬
        ↓
최신 10개 제외
        ↓
11번째 이후(오래된 로그) 선택
        ↓
삭제
```

구조.

---

# 왜 이런 구조를 사용하는가

로그는 계속 증가한다.

만약 제한이 없으면:

```text
디스크 용량 계속 증가
```

문제 발생 가능.

따라서 운영 서버에서는:
- 오래된 로그 삭제
- 로그 rotate
- 보관 개수 제한

등을 수행한다.

---

# 현재 프로젝트 목적

현재 프로젝트에서는:

```text
최신 로그는 유지
오래된 로그는 자동 삭제
```

구조를 구현한 것이다.

즉:

```text
운영 서버의 로그 관리 구조
```

를 단순화해서 구현한 형태.

---

# 현재 monitor.sh 로그 관리 흐름

```text
monitor.log 크기 확인
        ↓
10MB 초과 시
        ↓
새 이름으로 rotate
        ↓
새 monitor.log 생성
        ↓
최신 10개 로그 유지
        ↓
그보다 오래된 로그 삭제
```

---

# "혹시나를 위한 코드인가?"에 대한 답

단순 에러처리용은 아니다.

실제 서버 운영에서:

```text
로그 무한 증가 방지
```

를 위해 매우 흔하게 사용하는 관리 로직이다.

즉:

```text
운영 자동화의 핵심 기능 중 하나
```

라고 볼 수 있다.