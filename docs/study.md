# SSH

SSH는 원격 리눅스 서버에 안전하게 접속하기 위한 프로토콜이다.

## ssh와 sshd의 차이

### ssh
클라이언트 프로그램.

원격 서버에 접속 요청을 보낸다.

```bash
ssh user@host -p 20022
```

### sshd
SSH 서버 데몬.

클라이언트의 접속 요청을 기다린다.

```bash
/usr/sbin/sshd
```

## 현재 프로젝트에서의 역할

현재 프로젝트에서는:

- 컨테이너 내부 Ubuntu 서버 실행
- sshd 실행
- 포트 20022 LISTEN
- 로컬 터미널에서 SSH 접속

구조로 동작한다.

```text
Mac Terminal
    ↓
ssh agent-admin@localhost -p 20022
    ↓
Docker Container Ubuntu
    ↓
sshd
```

# Docker Container

Docker Container는 격리된 리눅스 실행 환경이다.

운영체제 전체를 가상화하는 VM(Virtual Machine)과 다르게,
컨테이너는 Host OS의 커널을 공유하면서 프로세스를 격리하여 실행한다.

## 컨테이너의 특징

- 빠른 실행 속도
- 가벼운 리소스 사용
- 독립된 파일 시스템
- 독립된 프로세스 공간
- 독립된 네트워크 환경

## 현재 프로젝트에서의 역할

현재 프로젝트에서는 Ubuntu 컨테이너를 하나의 리눅스 서버처럼 사용하였다.

```bash
docker run -it \
  --name codyssey-week1 \
  -p 20022:20022 \
  -p 15034:15034 \
  -v $(pwd):/workspace \
  ubuntu:24.04 bash
```

## 주요 옵션

### -it

interactive terminal.

컨테이너 내부 bash를 직접 조작 가능하게 만든다.

### --name

컨테이너 이름 지정.

```text
codyssey-week1
```

### -p

포트 포워딩.

```text
호스트 포트 : 컨테이너 포트
```

예:

```bash
-p 20022:20022
```

의미:

```text
Mac의 20022 포트
→ 컨테이너의 20022 포트 연결
```

### -v

볼륨 마운트.

```text
호스트 디렉토리 ↔ 컨테이너 디렉토리 연결
```

현재 프로젝트에서는:

```bash
-v $(pwd):/workspace
```

를 통해 GitHub 레포와 컨테이너 내부를 연결하였다.

---

# Linux Process

프로세스는 실행 중인 프로그램이다.

예:

- bash
- sshd
- cron
- agent-app

전부 프로세스이다.

## 프로세스 확인

```bash
ps -ef
```

또는

```bash
pgrep
```

사용.

## PID

PID(Process ID)는 프로세스 고유 번호이다.

예:

```text
PID:5051
```

---

# Container와 Process의 관계

컨테이너 안에는 여러 프로세스가 실행될 수 있다.

예:

```text
Container
 ├── bash
 ├── sshd
 ├── cron
 └── agent-app
```

## PID 1

컨테이너의 메인 프로세스.

PID 1이 종료되면 컨테이너도 종료된다.

현재 프로젝트에서는:

```bash
bash
```

가 메인 프로세스 역할을 수행하였다.

---

# docker exec

실행 중인 컨테이너 내부에 새로운 프로세스로 접속하는 명령어.

```bash
docker exec -it codyssey-week1 bash
```

의미:

```text
실행 중인 컨테이너 내부에
새로운 bash 프로세스 생성
```

---

# Linux User & Group

Linux는 사용자와 그룹 기반으로 권한을 관리한다.

## User

개별 사용자 계정.

예:

- agent-admin
- agent-dev
- agent-test

## Group

사용자 묶음.

예:

- agent-common
- agent-core

## 현재 프로젝트 구조

```text
agent-common
 ├── agent-admin
 ├── agent-dev
 └── agent-test

agent-core
 ├── agent-admin
 └── agent-dev
```

---

# chmod

파일/디렉토리 권한 변경 명령어.

```bash
chmod 750 monitor.sh
```

## 권한 구조

```text
750
│││
││└─ others
│└── group
└─── owner
```

## 숫자 의미

```text
4 = read
2 = write
1 = execute
```

## 예시

```text
7 = rwx
5 = r-x
0 = ---
```

즉:

```text
750 = rwx r-x ---
```

의미.

---

# chown

파일/디렉토리 소유자 변경 명령어.

```bash
chown agent-dev:agent-core monitor.sh
```

의미:

```text
owner = agent-dev
group = agent-core
```

---

# 최소 권한 원칙

필요한 사용자만 접근 가능하도록 제한하는 보안 원칙.

## 현재 프로젝트 예시

### upload_files

협업 공간.

```text
group = agent-common
```

### api_keys

민감 정보 저장소.

```text
group = agent-core
```

### monitor.log

운영 로그 저장소.

```text
group = agent-core
```

---

# SSH

SSH는 원격 리눅스 서버 접속 프로토콜이다.

## ssh

클라이언트 프로그램.

```bash
ssh agent-admin@localhost -p 20022
```

## sshd

SSH 서버 데몬.

클라이언트 접속 요청을 대기한다.

```bash
/usr/sbin/sshd
```

---

# Port

포트는 네트워크 통신 출입구이다.

하나의 서버에서 여러 서비스가 동시에 동작하기 위해 사용한다.

## 현재 프로젝트 포트

| 포트 | 역할 |
|---|---|
| 20022 | SSH |
| 15034 | agent-app |

---

# LISTEN

프로세스가 네트워크 연결을 기다리는 상태.

```bash
ss -tulnp
```

출력 예시:

```text
0.0.0.0:20022 LISTEN
```

의미:

```text
모든 인터페이스에서
20022 포트 연결 대기 중
```

---

# monitor.sh

시스템 상태 자동 점검 Bash Script.

## 역할

- 프로세스 확인
- 포트 확인
- 방화벽 확인
- CPU 확인
- 메모리 확인
- 디스크 확인
- 로그 기록
- 로그 로테이션

## Health Check

서비스 정상 동작 여부 확인.

### Process Check

```bash
pgrep -f
```

### Port Check

```bash
ss -tuln
```

---

# CPU / MEM / DISK Monitoring

시스템 자원 상태 수집.

## CPU

```bash
top
```

## Memory

```bash
free
```

## Disk

```bash
df
```

---

# Threshold Warning

임계값 초과 시 경고 출력.

현재 프로젝트 기준:

```text
CPU > 20%
MEM > 10%
DISK > 80%
```

---

# Logging

시스템 상태를 파일에 기록하는 작업.

## 현재 프로젝트 로그 파일

```text
/var/log/agent-app/monitor.log
```

## 로그 목적

- 운영 상태 기록
- 장애 분석
- 시스템 추적
- 모니터링 자동화

---

# Log Rotation

로그 파일이 너무 커지는 것을 방지하는 기법.

현재 프로젝트 기준:

```text
10MB 초과 시 rotate
최대 10개 유지
```

---

# cron

Linux 작업 스케줄러.

특정 작업을 자동 반복 실행한다.

## cron daemon

백그라운드에서 계속 실행되는 예약 관리자.

```bash
service cron start
```

---

# crontab

예약 작업 목록.

## 현재 프로젝트 설정

```cron
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

의미:

```text
매 1분마다 monitor.sh 실행
```

---

# cron 동작 흐름

```text
cron daemon
    ↓
crontab 확인
    ↓
monitor.sh 실행
    ↓
monitor.log 기록
```

---

# UFW

Ubuntu Firewall.

네트워크 접근 제어 도구.

## 역할

필요한 포트만 허용하고 나머지는 차단한다.

## 현재 프로젝트 설정

```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
```

## 의미

```text
SSH 포트 허용
agent-app 포트 허용
```

---

# 시스템 모니터링 자동화

현재 프로젝트 전체 흐름.

```text
Docker Container 실행
        ↓
Ubuntu 환경 구성
        ↓
sshd 실행
        ↓
agent-app 실행
        ↓
monitor.sh 실행
        ↓
cron 자동화
        ↓
monitor.log 누적
```


# SSH를 사용하는 이유

SSH(Secure Shell)는 원격 서버에 안전하게 접속하기 위한 프로토콜이다.

현재 프로젝트에서는:

```text
Mac Terminal
    ↓
SSH
    ↓
Docker Container Ubuntu
```

구조로 사용하였다.

즉:

```text
컨테이너 내부 Ubuntu 서버를
원격 리눅스 서버처럼 관리
```

하기 위해 SSH를 사용한 것이다.

---

# SSH를 사용하는 목적

## 원격 서버 관리

물리적으로 서버 앞에 가지 않아도 터미널로 접속 가능하다.

예:

```bash
ssh agent-admin@localhost -p 20022
```

현재 프로젝트에서는 localhost였지만,
실제 서버 환경에서는:

```text
AWS
Ubuntu Server
사내 Linux 서버
라즈베리파이
```

등에도 동일하게 사용된다.

---

# 보안 통신

SSH는 데이터를 암호화해서 전송한다.

즉:

```text
패스워드
명령어
파일
```

등이 네트워크에서 암호화된다.

---

# 터미널 기반 서버 운영

리눅스 서버는 GUI 없이 운영되는 경우가 많다.

즉:

```text
CLI(Command Line Interface)
```

환경에서 관리하는 경우가 대부분이다.

SSH는 이러한 CLI 서버 관리의 표준 도구이다.

---

# 현재 프로젝트에서 SSH 역할

현재 프로젝트에서는:

- Docker 컨테이너를 서버처럼 사용
- sshd 실행
- 포트 20022 LISTEN
- 외부 터미널에서 접속

구조로 사용하였다.

즉:

```text
컨테이너 내부 Ubuntu를
실제 Linux 서버처럼 운영
```

하는 환경을 만든 것이다.

---

# SSH 없이 작업하면 생기는 문제

## 컨테이너 내부 직접 접속만 가능

SSH를 사용하지 않으면:

```bash
docker exec -it container bash
```

처럼 Host에서 직접 컨테이너를 조작해야 한다.

즉:

```text
외부 네트워크 접속 불가능
```

상태가 된다.

---

# 실제 서버 운영 구조를 경험하기 어려움

SSH 없이 작업하면:

```text
원격 서버 운영 경험
```

을 얻기 어렵다.

현재 프로젝트 핵심은:

```text
"서버처럼 운영"
```

하는 경험이다.

---

# 사용자 기반 접근 제어가 제한적

SSH 환경에서는:

- 사용자 계정 분리
- 권한 분리
- 로그인 제한
- root 접속 차단

등을 적용 가능하다.

즉:

```text
보안 정책 적용 가능
```

해진다.

---

# 자동화 및 운영 구조 학습 제한

실제 운영 환경에서는:

- SSH
- cron
- systemd
- monitoring

등이 함께 사용된다.

SSH를 사용하지 않으면:
- 실제 운영 흐름 이해가 어려워진다.

---

# SSH와 docker exec 차이

## docker exec

```bash
docker exec -it container bash
```

의미:

```text
Host가 직접 컨테이너 내부 bash 실행
```

즉:
- Docker 권한 필요
- Host 접근 권한 필요
- 로컬 관리 중심

---

## SSH

```bash
ssh user@host -p 20022
```

의미:

```text
네트워크 기반 원격 접속
```

즉:
- 외부 터미널 가능
- 사용자 인증 가능
- 서버 운영 구조와 유사

---

# SSH의 핵심 구성 요소

## ssh

클라이언트 프로그램.

접속 요청을 보낸다.

```bash
ssh user@host
```

---

## sshd

SSH 서버 데몬.

클라이언트 접속을 기다린다.

```bash
/usr/sbin/sshd
```

---

# SSH 포트

기본 SSH 포트:

```text
22
```

현재 프로젝트에서는:

```text
20022
```

사용.

## 포트를 변경하는 이유

기본 포트 22는 공격 대상이 되기 쉽다.

따라서:

```text
비표준 포트 사용
```

을 통해:
- 단순 자동 스캔 감소
- 기본 공격 감소

효과를 얻는다.

---

# Root SSH 접속 차단 이유

현재 프로젝트 설정:

```text
PermitRootLogin no
```

## 이유

root 계정은 모든 권한을 가진다.

즉:
- 계정 탈취 시 서버 전체 위험
- 실수 발생 시 피해 큼

따라서 일반 사용자로 로그인 후:

```bash
sudo
```

를 사용하는 구조가 일반적이다.

---

# SSH 외의 다른 방안

# docker exec

현재 프로젝트에서도 사용한 방식.

```bash
docker exec -it container bash
```

## 장점

- 간단함
- 설정 필요 적음

## 단점

- 원격 접속 구조 아님
- 사용자 인증 구조 약함
- 실제 서버 운영과 다름

---

# Telnet

과거 원격 접속 방식.

```text
암호화 없음
```

이 가장 큰 문제.

현재는 거의 사용하지 않는다.

---

# Web Console

예:

- Portainer
- Cockpit
- AWS Console

브라우저 기반 서버 관리.

## 장점

- GUI 제공
- 사용 쉬움

## 단점

- 리눅스 내부 구조 학습 제한
- CLI 운영 능력 부족 가능

---

# Remote Desktop

예:

- VNC
- RDP

GUI 원격 접속 방식.

주로 Windows 환경에서 사용된다.

Linux 서버 운영에서는:
- SSH가 훨씬 일반적이다.

---

# SSH가 실무에서 중요한 이유

실제 Linux 서버 운영에서는 거의 기본이다.

예:

- AWS EC2
- Ubuntu Server
- Kubernetes Node
- 회사 내부 서버
- 라즈베리파이
- NAS

등 대부분 SSH 기반으로 관리한다.

---

# 현재 프로젝트 전체 SSH 흐름

```text
Mac Terminal
    ↓
ssh agent-admin@localhost -p 20022
    ↓
Docker Port Forwarding
    ↓
Container Ubuntu
    ↓
sshd
    ↓
agent-admin shell
```

---

# 현재 프로젝트에서 SSH를 통해 학습한 내용

- Linux 원격 접속 구조
- ssh와 sshd 차이
- 포트 기반 서비스 운영
- Root 로그인 차단
- 사용자 기반 인증
- Linux 서버 운영 흐름
- 컨테이너를 서버처럼 사용하는 방법



# upload_files

upload_files는 디렉토리(폴더)이다.

## 현재 위치

```text
/home/agent-admin/agent-app/upload_files
```

## 역할

공유 업로드 공간.

현재 프로젝트에서는:

```text
여러 사용자가 함께 접근 가능한 협업 공간
```

개념으로 사용하였다.

예를 들어:
- 업로드 파일 저장
- 공유 데이터 저장
- 공용 작업 파일 저장

등의 역할을 수행할 수 있다.

---

## 현재 권한 구조

```text
owner : agent-admin
group : agent-common
permission : 770
```

즉:

```text
agent-common 그룹 사용자들은 접근 가능
```

상태이다.

현재 포함 사용자:

- agent-admin
- agent-dev
- agent-test

---

## 현재 구조

```text
upload_files
 ├── 업로드 파일
 ├── 공유 데이터
 └── 협업 리소스
```

---

# api_keys

api_keys는 디렉토리(폴더)이다.

## 현재 위치

```text
/home/agent-admin/agent-app/api_keys
```

## 역할

민감 정보 저장소.

현재 프로젝트에서는:

```text
API Key
Secret Key
Token
```

같은 민감 정보를 저장하는 공간 역할이다.

예:

```text
t_secret.key
```

파일 저장.

---

## 현재 권한 구조

```text
owner : agent-admin
group : agent-core
permission : 770
```

즉:

```text
agent-core 그룹 사용자만 접근 가능
```

상태이다.

현재 포함 사용자:

- agent-admin
- agent-dev

---

## 왜 권한을 더 강하게 제한했는가

API Key는 민감 정보이다.

즉:
- 외부 유출 위험
- 인증 우회 위험
- 서비스 탈취 위험

등이 존재한다.

따라서:

```text
최소 권한 원칙
```

을 적용하였다.

---

## 현재 구조

```text
api_keys
 ├── t_secret.key
 ├── service.key
 └── secret.token
```

같은 구조를 가질 수 있다.

---

# monitor.log

monitor.log는 파일(File)이다.

## 현재 위치

```text
/var/log/agent-app/monitor.log
```

## 역할

시스템 상태 기록 파일.

현재 프로젝트에서는 monitor.sh가:

- CPU 사용률
- 메모리 사용률
- 디스크 사용률
- PID 상태

등을 기록한다.

---

## 로그 예시

```text
[2026-05-13 16:10:01]
PID:5051
CPU:17.5%
MEM:5.4%
DISK_USED:1%
```

---

# /var/log 디렉토리 의미

Linux에서:

```text
/var/log
```

는 시스템 로그 저장 위치이다.

즉 현재 프로젝트도:

```text
Linux 표준 로그 구조
```

를 따라간 것이다.

---

# monitor.log 권한 구조

현재 monitor.log는:

```text
owner : agent-admin
group : agent-core
permission : 660
```

상태로 구성하였다.

즉:

```text
agent-core 그룹 사용자만 로그 접근 가능
```

상태이다.

---

# monitor.log 역할

## 운영 상태 기록

서버 상태 추적.

---

## 장애 분석

문제 발생 시:
- CPU 폭주
- 메모리 증가
- 서비스 장애

등 분석 가능.

---

## 자동 모니터링 기록

cron이 monitor.sh를 반복 실행하면서:

```text
monitor.log
```

에 자동 append 수행.

---

# 현재 프로젝트 전체 구조

```text
/home/agent-admin/agent-app
 ├── upload_files/
 ├── api_keys/
 └── bin/

 /var/log/agent-app
 └── monitor.log
```

---

# 현재 프로젝트에서 각 공간의 역할

| 이름 | 종류 | 역할 |
|---|---|---|
| upload_files | 디렉토리 | 공유 업로드 공간 |
| api_keys | 디렉토리 | 민감 정보 저장소 |
| monitor.log | 파일 | 시스템 운영 로그 |

---

# 왜 전부 권한을 다르게 설정했는가

각 데이터의 민감도가 다르기 때문이다.

## upload_files

공유 목적.

비교적 접근 범위 넓음.

---

## api_keys

민감 정보.

접근 범위 제한 필요.

---

## monitor.log

운영 정보.

관리 그룹만 접근 가능하도록 제한.

---

# 현재 프로젝트의 보안 구조 핵심

```text
데이터 성격에 따라
권한을 분리하여 관리
```

하는 구조이다.

즉:

```text
협업 데이터
민감 데이터
운영 데이터
```

를 각각 분리한 것이다.