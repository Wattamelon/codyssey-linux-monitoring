# Codyssey Linux Monitoring Project

Docker 기반 Ubuntu 서버 환경에서 SSH 서버 구축, 역할 기반 권한 관리, UFW 방화벽 설정, monitor.sh 시스템 모니터링, cron 자동화까지 구성한 Linux 운영 실습 프로젝트입니다.

---

# 프로젝트 목표

- Docker 기반 Ubuntu 서버 환경 구축
- SSH 포트 변경 및 Root 원격 접속 차단
- 역할 기반 계정 / 그룹 / 권한 분리
- UFW 기반 최소 포트 허용 정책 구성
- monitor.sh 기반 시스템 모니터링 자동화
- cron 기반 자동 실행 및 로그 기록
- 트러블슈팅 및 운영 로그 문서화

---

# 사용 환경

| 항목 | 내용 |
|---|---|
| Host OS | macOS |
| Container Runtime | Docker |
| Container OS | Ubuntu 24.04 |
| SSH Port | 20022 |
| App Port | 15034 |

---

# 프로젝트 구조

```text
codyssey-linux-monitoring/
├── app/
│   └── agent-app
├── scripts/
│   └── monitor.sh
├── docs/
│   ├── command.md
│   ├── trouble_1.md
│   ├── trouble_2.md
│   └── trouble_3.md
└── README.md
```

---

# 주요 기능

## 1. SSH 서버 구축

- SSH 포트 20022 변경
- Root 원격 접속 차단
- 일반 계정 기반 접속 구성

```text
Port 20022
PermitRootLogin no
```

---

## 2. 역할 기반 권한 관리

### 계정

- agent-admin
- agent-dev
- agent-test

### 그룹

- agent-common
- agent-core

### 권한 구조

| 디렉토리 | 목적 | 권한 그룹 |
|---|---|---|
| upload_files | 협업 공유 공간 | agent-common |
| api_keys | 민감 정보 저장소 | agent-core |
| /var/log/agent-app | 운영 로그 저장 | agent-core |

---

## 3. UFW 방화벽 설정

허용 포트만 개방:

```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
```

허용 포트:
- 20022 → SSH
- 15034 → agent-app

---

## 4. monitor.sh 시스템 모니터링

monitor.sh에서 수행하는 기능:

- agent-app 프로세스 확인
- 15034 포트 LISTEN 상태 확인
- UFW 활성 상태 확인
- CPU / Memory / Disk 사용량 확인
- threshold 초과 시 warning 출력
- monitor.log 기록
- 로그 로테이션 수행

---

## 5. cron 자동화

매 1분마다 monitor.sh 자동 실행:

```cron
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

자동으로:
- 시스템 상태 확인
- 로그 append
- 운영 상태 기록

을 수행한다.

---

# 실행 흐름

```text
Docker Container Start
        ↓
SSH Server 실행
        ↓
agent-app 실행
        ↓
monitor.sh 실행
        ↓
cron 자동화
        ↓
monitor.log 누적
```

---

# 주요 명령어

## 컨테이너 실행

```bash
docker run -it \
  --name codyssey-week1 \
  --privileged \
  -p 20022:20022 \
  -p 15034:15034 \
  -v $(pwd):/workspace \
  ubuntu:24.04 bash
```

## SSH 포트 확인

```bash
ss -tulnp | grep 20022
```

## App 포트 확인

```bash
ss -tulnp | grep 15034
```

## 방화벽 상태 확인

```bash
ufw status
```

## cron 확인

```bash
crontab -u agent-admin -l
```

## 로그 확인

```bash
tail -n 20 /var/log/agent-app/monitor.log
```

---

# 트러블슈팅

## 1. SSH 포트 변경 후 LISTEN 안 됨

원인:
- sshd 재시작 미수행

해결:
```bash
pkill sshd
/usr/sbin/sshd
```

---

## 2. Docker 컨테이너에서 UFW 활성화 실패

원인:
- Docker capability 제한

해결:
```bash
docker run --privileged ...
```

---

## 3. cron 자동 실행 시 monitor.log Permission denied

원인:
- monitor.log write 권한 부족

해결:
```bash
chown agent-admin:agent-core /var/log/agent-app/monitor.log
chmod 660 /var/log/agent-app/monitor.log
```

---

# 학습한 내용

- Docker 컨테이너와 Linux 서버 구조
- SSH 서버 동작 방식
- Port Forwarding 개념
- Linux 계정 / 그룹 / 권한 구조
- ACL 기반 권한 제어
- UFW 및 iptables 개념
- cron 기반 작업 자동화
- 시스템 모니터링 및 로그 운영
- Linux 운영 환경 트러블슈팅 방법

---

# 결과

- SSH 서버 정상 동작
- Root 원격 접속 차단 성공
- 역할 기반 권한 구조 구성 완료
- UFW 최소 포트 허용 정책 적용 완료
- monitor.sh 시스템 모니터링 성공
- cron 자동 실행 및 로그 누적 성공