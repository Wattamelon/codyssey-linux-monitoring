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



# SSH 서버 설정 과정

현재 프로젝트에서는 Docker 컨테이너 내부 Ubuntu를 실제 Linux 서버처럼 운영하기 위해 SSH 서버를 구축하였다.

즉:

```text
Mac Terminal
    ↓
SSH 접속
    ↓
Docker Ubuntu Container
```

구조를 만든 것이다.

---

# SSH 설정 파일 수정

```bash
nano /etc/ssh/sshd_config
```

## 의미

```text
sshd_config
```

는 SSH 서버(sshd)의 설정 파일이다.

즉:
- 어떤 포트를 사용할지
- root 로그인을 허용할지
- 인증 방식을 어떻게 할지

등을 설정한다.

---

# Root 로그인 차단

기존 설정:

```text
#PermitRootLogin prohibit-password
```

수정 후:

```text
PermitRootLogin no
```

## 의미

root 계정으로 SSH 원격 접속을 금지한다는 뜻.

즉:

```text
ssh root@server
```

접속 차단.

---

# 왜 Root 로그인을 차단하는가

root는 Linux 최고 권한 계정이다.

즉:
- 모든 파일 접근 가능
- 모든 명령 실행 가능
- 시스템 삭제 가능

상태이다.

따라서:
- 계정 탈취 위험
- 무차별 로그인 공격 위험
- 실수로 시스템 손상 가능성

등이 존재한다.

실제 서버 운영에서는:
- 일반 계정 로그인
- sudo 사용

구조가 일반적이다.

---

# SSH 포트 변경

추가 설정:

```text
Port 20022
```

## 의미

SSH 서버가:

```text
22번 포트 대신
20022 포트 사용
```

하도록 설정한 것이다.

---

# 왜 포트를 변경하는가

기본 SSH 포트는:

```text
22
```

이다.

하지만:
- 자동 공격 스캔
- 브루트포스 공격
- 무차별 로그인 시도

등이 집중되는 포트이다.

따라서:

```text
비표준 포트 사용
```

을 통해:
- 단순 공격 감소
- 기본 스캔 감소

효과를 얻을 수 있다.

---

# /run/sshd 디렉토리 생성

```bash
mkdir -p /run/sshd
```

## 의미

SSH 서버가 실행될 때 사용하는 런타임 디렉토리 생성.

---

# /run 디렉토리 의미

Linux의:

```text
/run
```

디렉토리는 실행 중인 서비스의 임시 런타임 데이터를 저장하는 공간이다.

예:
- PID 파일
- 소켓 파일
- lock 파일

등 저장.

---

# 왜 /run/sshd가 필요한가

sshd는 실행 중:
- 프로세스 상태
- 소켓 정보
- PID 정보

등을 저장해야 한다.

따라서:

```text
/run/sshd
```

디렉토리가 필요하다.

없으면 sshd 실행 실패 가능.

---

# SSH 서버 실행

```bash
/usr/sbin/sshd
```

## 의미

SSH 서버 데몬 실행.

---

# sshd란

SSH Server Daemon.

클라이언트의 SSH 접속 요청을 기다리는 서버 프로세스이다.

즉:

```text
Mac Terminal
    ↓
ssh 접속 요청
    ↓
sshd가 요청 수신
```

구조로 동작한다.

---

# 열린 포트 확인

```bash
ss -tulnp | grep 20022
```

## ss 명령어

네트워크 소켓 상태 확인 명령어.

---

# 옵션 의미

| 옵션 | 의미 |
|---|---|
| -t | TCP |
| -u | UDP |
| -l | LISTEN 상태 |
| -n | 포트 숫자 그대로 출력 |
| -p | 프로세스 정보 출력 |

---

# grep 20022 의미

출력 결과 중:

```text
20022
```

포트만 필터링.

---

# 출력 결과 해석

```text
0.0.0.0:20022 LISTEN
```

의미:

```text
모든 네트워크 인터페이스에서
20022 포트 연결 대기 중
```

---

# users:(("sshd"...))

의미:

```text
현재 20022 포트를
sshd 프로세스가 사용 중
```

이라는 뜻.

---

# 일반 계정 생성

```bash
adduser agent-admin
```

## 의미

새 Linux 사용자 생성.

현재 프로젝트에서는:
- agent-admin
- agent-dev
- agent-test

계정을 생성하였다.

---

# adduser 실행 시 발생하는 작업

## 사용자 생성

```text
agent-admin
```

계정 생성.

---

## 그룹 생성

```text
agent-admin
```

이름의 그룹 자동 생성.

Linux에서는:
- 사용자 전용 그룹을 함께 생성하는 경우가 많다.

---

## 홈 디렉토리 생성

```text
/home/agent-admin
```

생성.

사용자 개인 작업 공간 역할.

---

## 기본 설정 파일 복사

```text
/etc/skel
```

의 기본 shell 설정 파일을 홈 디렉토리로 복사.

예:
- .bashrc
- .profile

등.

---

# 비밀번호 설정

```text
New password:
```

입력.

현재 과정에서:

```text
Sorry, passwords do not match.
```

오류 발생.

즉:
- 비밀번호 재입력 값 불일치.

다시 입력 후 정상 생성 완료.

---

# 사용자 정보 입력

```text
Full Name
Room Number
Phone
```

등은 선택 사항이다.

ENTER만 눌러도 된다.

---

# id 명령어

```bash
id agent-admin
```

## 의미

사용자의:
- UID
- GID
- 그룹 정보

출력.

---

# uid

User ID.

Linux 내부 사용자 번호.

예:

```text
uid=1000
```

---

# gid

Group ID.

사용자 기본 그룹 번호.

예:

```text
gid=1000
```

---

# groups

현재 사용자가 속한 그룹 목록.

현재 상태에서는:

```text
groups=1000(agent-admin)
```

즉:
- 아직 추가 그룹 미설정 상태.

이후:

```bash
usermod -aG
```

로:
- agent-common
- agent-core

그룹에 추가하였다.

---

# 현재 프로젝트에서 일반 계정을 만든 이유

실제 Linux 서버 운영에서는:
- 사용자별 권한 분리
- 역할 기반 접근 제어
- 보안 관리

가 중요하다.

즉:
- 관리자
- 개발자
- 테스트 사용자

를 분리하여 운영하는 구조를 연습한 것이다.

---

# 현재 프로젝트 전체 흐름

```text
Docker Ubuntu 실행
        ↓
SSH 서버 구축
        ↓
sshd 실행
        ↓
포트 20022 LISTEN
        ↓
일반 사용자 생성
        ↓
SSH 원격 접속 가능 상태
```


# Root 계정을 직접 사용하지 않는 이유

현재 프로젝트에서는:

```text
PermitRootLogin no
```

설정을 통해 Root SSH 로그인을 차단하였다.

대신:

```text
일반 사용자 로그인
→ 필요 시 sudo 사용
```

구조를 사용하였다.

---

# "어차피 sudo 쓰면 root 되는 거 아닌가?"

겉보기에는 맞는 말처럼 보인다.

왜냐면:

```bash
sudo apt install nginx
```

같은 명령은 결국 Root 권한으로 실행되기 때문이다.

하지만 실제 보안에서는:

```text
"항상 Root 상태"
```

와

```text
"필요할 때만 잠깐 Root 권한 사용"
```

은 매우 큰 차이가 있다.

---

# Root 계정 직접 사용의 문제점

## 모든 명령이 최고 권한

Root 상태에서는:

```bash
rm -rf /
```

같은 위험한 명령도 즉시 실행 가능하다.

즉:
- 실수
- 오타
- 잘못된 스크립트

가 시스템 전체 문제로 이어질 수 있다.

---

# 일반 사용자 + sudo 구조

일반 사용자는:

```text
기본적으로 제한된 권한
```

상태이다.

즉:
- 시스템 파일 수정 불가
- 중요한 설정 변경 불가

상태.

필요한 순간만:

```bash
sudo
```

를 통해 잠깐 권한 상승.

---

# sudo의 핵심 개념

sudo는:

```text
"특정 명령만 잠깐 Root 권한으로 실행"
```

하는 시스템이다.

즉:

```text
항상 Root
```

가 아니다.

---

# 보안적으로 중요한 이유

## 공격 범위 감소

만약 계정이 탈취되더라도:

- 일반 사용자 상태
- sudo 비밀번호 필요
- sudo 권한 제한 가능

등 추가 방어막 존재.

---

# 감사(Audit) 가능

sudo 사용 기록은 로그로 남는다.

즉:

```text
누가
언제
어떤 명령을 실행했는지
```

추적 가능.

---

# 역할 기반 운영 가능

실제 서버에서는:
- 관리자
- 개발자
- 운영자

권한을 다르게 준다.

예:

```text
A는 nginx 재시작 가능
B는 docker만 가능
C는 sudo 불가
```

등 세밀하게 관리 가능.

---

# 실무 서버 구조

실제 Linux 서버에서는 거의 대부분:

```text
Root 직접 로그인 금지
```

구조를 사용한다.

예:
- AWS EC2
- Ubuntu Server
- 회사 서버
- Kubernetes Node

등.

---

# 핵심 차이

## Root 직접 로그인

```text
처음부터 끝까지 최고 권한
```

---

## 일반 사용자 + sudo

```text
기본은 제한 권한
필요한 순간만 권한 상승
```

---

# /usr/sbin/sshd 는 무엇인가

```bash
/usr/sbin/sshd
```

는:

```text
SSH 서버 프로그램 실행 파일
```

이다.

---

# 왜 내가 만든 기억이 없나

왜냐면:

```text
openssh-server 패키지 설치 시
자동 설치
```

되었기 때문이다.

현재 프로젝트에서 실행했던:

```bash
apt install openssh-server
```

이 명령이:
- sshd 프로그램
- 설정 파일
- 기본 SSH 환경

등을 자동 설치한 것이다.

---

# Linux 프로그램 설치 구조

Linux에서는 프로그램 설치 시:

```text
실행 파일(binary)
```

이 특정 디렉토리에 저장된다.

예:

| 경로 | 의미 |
|---|---|
| /bin | 기본 사용자 명령 |
| /usr/bin | 일반 프로그램 |
| /sbin | 시스템 관리 명령 |
| /usr/sbin | 시스템 서비스 프로그램 |

---

# /usr/sbin 의미

```text
system binary
```

계열 디렉토리.

즉:
- 관리자용 시스템 프로그램
- 서비스 데몬

등 저장.

---

# sshd가 왜 /usr/sbin 에 있는가

sshd는:
- 시스템 서비스
- 네트워크 서버 데몬

이기 때문이다.

즉 일반 사용자 프로그램보다:

```text
시스템 관리 서비스
```

에 가까운 프로그램이다.

---

# ssh 와 sshd 차이

## ssh

클라이언트 프로그램.

접속 요청을 보낸다.

예:

```bash
ssh user@host
```

---

## sshd

서버 데몬.

접속 요청을 기다린다.

예:

```bash
/usr/sbin/sshd
```

---

# 현재 프로젝트 흐름

```text
Mac Terminal
    ↓
ssh agent-admin@localhost -p 20022
    ↓
Container Ubuntu
    ↓
sshd가 요청 수신
    ↓
로그인 인증
    ↓
shell 제공
```

---

# daemon 이란

daemon(데몬)은:

```text
백그라운드에서 계속 실행되는 서비스 프로세스
```

이다.

예:
- sshd
- cron
- nginx
- mysqld

등.

---

# /usr/sbin/sshd 실행 의미

```bash
/usr/sbin/sshd
```

실행 시:

```text
SSH 서버 프로세스 시작
```

된다.

그러면:
- 20022 포트 LISTEN
- SSH 접속 대기

상태가 된다.

---

# 현재 프로젝트에서 sshd 역할

현재 프로젝트에서는 sshd가:

```text
컨테이너를
원격 접속 가능한 Linux 서버처럼 동작
```

하게 만들어 주었다.
---

# 디렉토리 생성

현재 프로젝트에서는 Linux 서버 운영 구조를 만들기 위해 여러 디렉토리를 생성하였다.

생성한 디렉토리:

```bash
mkdir -p /home/agent-admin/agent-app/upload_files
mkdir -p /home/agent-admin/agent-app/api_keys
mkdir -p /home/agent-admin/agent-app/bin
mkdir -p /var/log/agent-app
```

---

# mkdir

```bash
mkdir
```

는 디렉토리 생성 명령어이다.

---

# -p 옵션 의미

```bash
mkdir -p
```

의 의미:

```text
중간 경로까지 자동 생성
```

예:

```bash
mkdir -p /a/b/c
```

실행 시:
- a 없으면 생성
- b 없으면 생성
- c 생성

까지 한 번에 수행.

---

# 현재 프로젝트 디렉토리 구조

```text
/home/agent-admin/agent-app
 ├── upload_files
 ├── api_keys
 └── bin

/var/log/agent-app
```

구조 생성.

---

# /home 디렉토리 의미

Linux에서:

```text
/home
```

은 일반 사용자 홈 디렉토리 저장 위치이다.

현재 생성된 사용자:

```text
/home/agent-admin
/home/agent-dev
/home/agent-test
```

가 존재한다.

즉:
- 각 사용자 개인 작업 공간 역할.

---

# agent-app 디렉토리

```text
/home/agent-admin/agent-app
```

는 현재 프로젝트 애플리케이션 루트 디렉토리 역할이다.

즉:
- 프로그램
- 업로드 파일
- API Key
- 실행 스크립트

등을 저장하는 공간이다.

---

# upload_files 디렉토리

```text
/home/agent-admin/agent-app/upload_files
```

## 역할

공유 업로드 공간.

예:
- 업로드 파일
- 협업 데이터
- 공용 리소스

등 저장 가능.

---

# api_keys 디렉토리

```text
/home/agent-admin/agent-app/api_keys
```

## 역할

민감 정보 저장 공간.

예:
- API Key
- Secret Key
- Token

등 저장.

---

# bin 디렉토리

```text
/home/agent-admin/agent-app/bin
```

## 역할

실행 가능한 스크립트 저장 공간.

현재 프로젝트에서는:

```text
monitor.sh
```

저장 위치로 사용.

---

# /var/log 디렉토리 의미

Linux에서:

```text
/var/log
```

는 시스템 로그 저장 위치이다.

즉:
- 운영 로그
- 서비스 로그
- 시스템 로그

등을 저장하는 표준 디렉토리.

---

# /var/log/agent-app

```text
/var/log/agent-app
```

는 현재 프로젝트의 운영 로그 저장 공간이다.

즉:

```text
monitor.log
```

파일이 저장되는 위치.

---

# ls 명령어

```bash
ls
```

는 현재 디렉토리 내부 목록 출력 명령어.

---

# cd 명령어

```bash
cd
```

는 디렉토리 이동 명령어.

예:

```bash
cd /home
```

---

# upload_files 권한 설정

```bash
chown -R agent-admin:agent-common /home/agent-admin/agent-app/upload_files

chmod 770 /home/agent-admin/agent-app/upload_files
```

---

# chown 의미

```bash
chown
```

는 파일/디렉토리 소유자 변경 명령어.

---

# -R 옵션 의미

```bash
-R
```

의 의미:

```text
하위 파일/디렉토리까지 재귀적으로 적용
```

---

# 현재 설정 의미

```bash
chown -R agent-admin:agent-common
```

의 의미:

```text
owner = agent-admin
group = agent-common
```

---

# chmod 의미

```bash
chmod
```

는 권한 변경 명령어.

---

# 770 의미

```text
770 = rwx rwx ---
```

즉:

| 대상 | 권한 |
|---|---|
| owner | rwx |
| group | rwx |
| others | --- |

---

# upload_files 권한 구조 의미

현재:

```text
owner = agent-admin
group = agent-common
permission = 770
```

상태.

즉:
- agent-admin 접근 가능
- agent-common 그룹 접근 가능
- 나머지 사용자는 접근 불가

상태이다.

---

# 왜 agent-common 그룹 사용?

upload_files는:

```text
공유 협업 공간
```

개념이기 때문이다.

현재:
- agent-admin
- agent-dev
- agent-test

모두 접근 가능하도록 설계.

---

# api_keys 권한 설정

```bash
chown -R agent-admin:agent-core /home/agent-admin/agent-app/api_keys

chmod 770 /home/agent-admin/agent-app/api_keys
```

---

# api_keys 권한 구조 의미

현재:

```text
owner = agent-admin
group = agent-core
permission = 770
```

상태.

즉:
- agent-core 그룹만 접근 가능
- 일반 사용자는 접근 불가

상태.

---

# 왜 더 강하게 제한했는가

api_keys는:

```text
민감 정보 저장 공간
```

이기 때문이다.

예:
- API Key
- Secret Token
- 인증 정보

등 저장 가능.

따라서:
- 최소 권한 원칙 적용
- 접근 사용자 제한

구조로 설계.

---

# monitor.log 디렉토리 권한 설정

```bash
chown -R agent-admin:agent-core /var/log/agent-app

chmod 770 /var/log/agent-app
```

---

# 의미

운영 로그 디렉토리를:

```text
agent-core 그룹 전용
```

으로 제한한 것이다.

즉:
- 운영 로그는 민감 정보 가능성 존재
- 관리자 그룹만 접근 가능하도록 제한

구조.

---

# 왜 로그도 보호하는가

로그에는:
- 시스템 상태
- 프로세스 정보
- 서비스 정보

등이 기록된다.

즉:
- 내부 구조 노출 가능
- 운영 정보 노출 가능

상태.

따라서:
- 접근 제한 필요.

---

# 현재 프로젝트 전체 권한 구조

```text
upload_files
 → 협업 공간
 → agent-common 접근 가능

api_keys
 → 민감 정보
 → agent-core 접근 가능

monitor.log
 → 운영 로그
 → agent-core 접근 가능
```

---

# 현재 프로젝트 핵심 보안 개념

현재 프로젝트는:

```text
데이터 성격에 따라
권한을 분리
```

한 구조이다.

즉:

| 종류 | 특징 | 접근 범위 |
|---|---|---|
| 공유 데이터 | 협업 목적 | 넓음 |
| 민감 정보 | 보안 중요 | 제한 |
| 운영 로그 | 내부 정보 | 제한 |

구조로 나누어 관리하였다.

---

# 현재 프로젝트 전체 흐름

```text
사용자 생성
        ↓
그룹 생성
        ↓
디렉토리 생성
        ↓
데이터 역할 분리
        ↓
권한 설정
        ↓
보안 구조 구성
```


# 디렉토리를 agent-admin 아래에 생성했다는 의미

현재 생성한 디렉토리:

```bash
mkdir -p /home/agent-admin/agent-app/upload_files
mkdir -p /home/agent-admin/agent-app/api_keys
mkdir -p /home/agent-admin/agent-app/bin
```

는 모두:

```text
/home/agent-admin
```

아래에 생성되었다.

즉:

```text
agent-admin 사용자의 홈 디렉토리 내부
```

에 생성된 것이다.

---

# 기본적으로 누가 접근 가능한가

Linux에서는 파일/디렉토리를 생성하면:

```text
생성한 사용자(owner)
```

가 기본 소유자가 된다.

현재는:

```text
root 계정
```

에서 생성했기 때문에,
처음 생성 시 owner는 사실 root였다.

즉 초기 상태는 대략:

```text
owner = root
group = root
```

상태.

---

# 왜 이후에 chown을 수행했는가

그래서 이후에:

```bash
chown -R agent-admin:agent-common upload_files
```

같은 작업을 수행한 것이다.

즉:

```text
실제 owner를 agent-admin으로 변경
```

한 것.

---

# 현재 구조 해석

예를 들어:

```bash
chown -R agent-admin:agent-common upload_files
```

의 의미는:

```text
owner = agent-admin
group = agent-common
```

으로 변경하겠다는 뜻.

---

# owner와 group의 차이

## owner

파일/디렉토리의 실제 소유자.

즉:
- 가장 강한 권한 기준.
- owner 권한 적용.

현재:

```text
agent-admin
```

이 owner.

---

## group

공동 접근 그룹.

즉:
- 특정 사용자 집합에게 추가 접근 허용.

현재:

```text
agent-common
```

이 group.

---

# 질문 핵심 답변

맞아.

현재 권한 설정 과정의 핵심 목적은:

```text
agent-admin 외의 다른 사용자들에게
접근 권한을 부여하기 위한 과정
```

이라고 이해하면 된다.

---

# upload_files 예시

현재 설정:

```bash
chown -R agent-admin:agent-common upload_files
chmod 770 upload_files
```

의 의미:

```text
owner = agent-admin
group = agent-common
permission = rwx rwx ---
```

---

# 실제 접근 구조

## agent-admin

owner 권한으로 접근 가능.

---

## agent-common 그룹 사용자

group 권한으로 접근 가능.

현재:
- agent-dev
- agent-test

등 접근 가능.

---

## others

접근 불가능.

---

# 왜 group을 사용하는가

Linux는:

```text
여러 사용자에게
동일 권한 부여
```

를 효율적으로 하기 위해 group 개념을 사용한다.

---

# 현재 프로젝트 구조

```text
upload_files
 ├── owner : agent-admin
 └── group : agent-common
```

즉:

```text
agent-admin이 관리하지만,
agent-common 그룹도 함께 접근 가능
```

한 구조.

---

# api_keys는 왜 다르게 설정했는가

```bash
chown -R agent-admin:agent-core api_keys
chmod 770 api_keys
```

여기서는 group이:

```text
agent-core
```

이다.

즉:
- agent-common 전체 허용 X
- 더 제한된 사용자만 허용

구조.

---

# 현재 프로젝트의 핵심 개념

현재 구조는:

```text
owner 기반 관리
+
group 기반 협업 권한 부여
```

구조이다.

즉:

```text
agent-admin이 소유
→ 필요한 그룹만 접근 허용
```

하는 방식.

---

# 왜 이런 구조를 사용하는가

실제 서버에서는:
- 여러 사용자가 존재
- 역할이 다름
- 접근 가능한 데이터도 다름

즉:

```text
공유는 하되,
모든 사용자에게 다 열어두지는 않음
```

구조가 필요하다.

---

# 현재 프로젝트 흐름 정리

```text
디렉토리 생성
        ↓
owner 지정
        ↓
group 지정
        ↓
group 기반 접근 허용
        ↓
최소 권한 원칙 적용
```

---

# 현재 프로젝트에서 역할별 접근 구조

```text
upload_files
 → 협업 공간
 → agent-common 접근 가능

api_keys
 → 민감 정보
 → agent-core 접근 가능

monitor.log
 → 운영 로그
 → agent-core 접근 가능
```

즉:

```text
데이터 중요도에 따라
접근 범위를 다르게 설계
```

한 것이다.


# owner와 group의 권한이 둘 다 7이면 완전히 같은가?

현재 설정:

```bash
chown -R agent-admin:agent-common upload_files
chmod 770 upload_files
```

의 의미:

```text
owner = agent-admin
group = agent-common
permission = rwx rwx ---
```

즉:

| 대상 | 권한 |
|---|---|
| owner | rwx |
| group | rwx |
| others | --- |

상태이다.

겉보기에는:

```text
owner와 group 권한이 완전히 동일
```

해 보인다.

실제로:
- 읽기(read)
- 쓰기(write)
- 실행(execute)

권한 자체는 동일하다.

즉:
- 파일 생성
- 수정
- 삭제
- 디렉토리 접근

등은 둘 다 가능하다.

---

# 그런데 owner가 특별한 이유

Linux에서는:

```text
owner는 "진짜 소유자"
```

라는 개념이 존재한다.

즉 단순 rwx 외에도 owner만 가능한 영역이 있다.

---

# owner만 가능한 대표적인 작업

## chmod 가능

파일 owner는:

```bash
chmod
```

를 통해 권한 변경 가능.

group 사용자는:
- rwx 권한이 있어도
- 일반적으로 chmod 불가능.

---

# chown 가능

owner 변경은 보통:
- root
- 일부 특수 권한 사용자

만 가능.

즉 group 사용자에게는 거의 허용되지 않는다.

---

# ACL 및 메타데이터 관리

고급 권한 설정:
- ACL
- extended attribute

등도 owner/root 중심 관리.

---

# Linux 내부 기준도 owner 우선

Linux 권한 체크 순서는:

```text
owner 확인
    ↓
group 확인
    ↓
others 확인
```

순서이다.

즉:

```text
현재 사용자가 owner이면
group 권한은 아예 안 봄
```

---

# 예시

현재 구조:

```text
owner = agent-admin
group = agent-common
permission = 770
```

---

# agent-admin 접근 시

Linux는:

```text
"이 사용자는 owner네?"
```

라고 판단.

즉:
- owner 권한 적용
- group 권한은 무시.

---

# agent-dev 접근 시

agent-dev는 owner가 아니므로:

```text
group 권한 확인
```

으로 넘어간다.

그리고:
- agent-common 그룹 소속이면
- group 권한 적용.

---

# 즉 핵심 차이

## owner

```text
실제 소유자
```

---

## group

```text
공동 접근 허용 대상
```

---

# 현재 프로젝트 구조 관점

현재 구조는:

```text
agent-admin이 실제 관리 책임자
```

라는 의미가 포함되어 있다.

그리고:

```text
agent-common 그룹은 협업 접근 허용
```

개념.

즉:

```text
소유자(owner)
+
공유 그룹(group)
```

구조.

---

# 왜 이런 구조를 사용하는가

실제 서버에서는:
- 담당 관리자
- 개발자
- 운영자

등 역할이 다르다.

예:

```text
owner
 → 실제 서비스 관리자

group
 → 공동 작업자
```

처럼 사용하는 경우 많다.

---

# owner와 group 권한이 같아도 owner가 중요한 이유

현재는 둘 다:

```text
7 = rwx
```

지만,

owner는:
- 파일의 주체
- 권한 기준점
- 관리 책임자

역할을 가진다.

즉:

```text
권한 숫자는 같아도
의미는 다르다
```

고 이해하는 게 중요하다.

---

# 현재 프로젝트에서의 의미

```text
upload_files
 → agent-admin이 소유
 → agent-common이 협업 접근

api_keys
 → agent-admin이 소유
 → agent-core만 접근 허용
```

즉:
- owner는 관리 책임자
- group은 접근 허용 대상

개념으로 설계한 구조이다.


# ACL 확인

현재 프로젝트에서는 디렉토리 권한 설정 이후:

```bash
getfacl /home/agent-admin/agent-app/upload_files
getfacl /home/agent-admin/agent-app/api_keys
```

명령어를 사용하여 권한 상태를 확인하였다.

---

# getfacl 이란

```bash
getfacl
```

은 Linux의 ACL(Access Control List) 정보를 조회하는 명령어이다.

즉:

```text
파일/디렉토리 접근 권한 구조 확인
```

명령어.

---

# ACL 이란

ACL은:

```text
파일 접근 제어 목록
```

이다.

기본 Linux 권한 시스템보다 더 세부적인 접근 제어를 가능하게 만든다.

---

# 기본 Linux 권한 구조

일반 Linux 권한은:

```text
owner
group
others
```

3단계만 존재한다.

예:

```text
770
```

---

# ACL이 필요한 이유

기본 권한만으로는:

```text
특정 사용자만 추가 허용
```

같은 세밀한 제어가 어렵다.

ACL은:
- 사용자별 권한
- 그룹별 권한
- 세부 접근 정책

등을 추가 가능하게 만든다.

---

# 현재 프로젝트에서는 왜 getfacl을 사용했는가

현재 프로젝트에서는:

```text
권한 설정이 제대로 적용되었는지 검증
```

하기 위해 사용하였다.

즉:
- owner 확인
- group 확인
- rwx 권한 확인

용도.

---

# 출력 결과 해석

```text
# owner: agent-admin
# group: agent-common
```

의 의미:

| 항목 | 의미 |
|---|---|
| owner | 실제 소유자 |
| group | 공동 접근 그룹 |

---

# user::rwx

의미:

```text
owner 권한
```

현재:
- 읽기
- 쓰기
- 실행

전부 가능.

즉:

```text
rwx = 7
```

---

# group::rwx

의미:

```text
group 권한
```

현재:
- group 사용자들도
- 읽기/쓰기/실행 가능.

즉:

```text
rwx = 7
```

---

# other::---

의미

```text
기타 사용자 접근 불가
```

즉:
- owner도 아니고
- group도 아니면

접근 불가능.

---

# 현재 upload_files 구조 해석

```text
owner : agent-admin
group : agent-common
permission : rwx rwx ---
```

즉:

| 사용자 | 접근 가능 여부 |
|---|---|
| agent-admin | 가능 |
| agent-common 그룹 사용자 | 가능 |
| 그 외 사용자 | 불가능 |

---

# 현재 api_keys 구조 해석

```text
owner : agent-admin
group : agent-core
permission : rwx rwx ---
```

즉:

| 사용자 | 접근 가능 여부 |
|---|---|
| agent-admin | 가능 |
| agent-core 그룹 사용자 | 가능 |
| 그 외 사용자 | 불가능 |

---

# upload_files와 api_keys의 차이

## upload_files

```text
공유 협업 공간
```

현재:
- agent-common 그룹 접근 가능.

즉:
- agent-admin
- agent-dev
- agent-test

등 접근 가능.

---

# api_keys

```text
민감 정보 저장 공간
```

현재:
- agent-core 그룹만 접근 가능.

즉:
- agent-admin
- agent-dev

만 접근 가능.

---

# getfacl 경고 메시지 의미

출력:

```text
getfacl: Removing leading '/' from absolute path names
```

는 오류가 아니다.

---

# 의미

ACL 출력 시:

```text
절대경로의 맨 앞 '/'
```

를 제거해서 표시하겠다는 의미.

예:

원래:

```text
/home/agent-admin/...
```

출력 시:

```text
home/agent-admin/...
```

처럼 표시.

단순 출력 형식 처리일 뿐이다.

---

# 왜 ACL 확인이 중요한가

Linux 서버 운영에서는:

```text
권한 설정 후 반드시 검증
```

하는 과정이 중요하다.

왜냐면:
- 잘못된 권한
- 과도한 권한
- 접근 불가 문제

등이 자주 발생하기 때문이다.

---

# 현재 프로젝트에서 ACL 확인의 의미

현재 프로젝트에서는:

```text
설계한 보안 구조가
실제로 적용되었는지 검증
```

하는 과정이다.

즉:
- 공유 공간은 공유 가능
- 민감 정보는 제한
- others 접근 차단

구조가 정상인지 확인한 것이다.

---

# 현재 프로젝트 전체 권한 구조

```text
upload_files
 → 협업 공유 공간

api_keys
 → 민감 정보 저장 공간

monitor.log
 → 운영 로그 저장 공간
```

각 데이터 성격에 따라:
- owner
- group
- permission

을 다르게 설정하였다.

---

# 현재 프로젝트 핵심 보안 개념

현재 프로젝트는:

```text
데이터 중요도에 따라
접근 범위를 분리
```

한 구조이다.

즉:
- 공유 데이터
- 민감 정보
- 운영 데이터

를 서로 다른 권한 정책으로 관리한 것이다.


# 키 파일 생성

현재 프로젝트에서는 API Key와 같은 민감 정보를 저장하는 구조를 만들기 위해 키 파일을 생성하였다.

생성 명령어:

```bash
echo "agent_api_key_test" > /home/agent-admin/agent-app/api_keys/t_secret.key
```

---

# echo 명령어

```bash
echo
```

는 문자열 출력 명령어이다.

예:

```bash
echo "hello"
```

출력:

```text
hello
```

---

# > 리다이렉션 의미

현재 명령어:

```bash
echo "agent_api_key_test" > file
```

의:

```text
>
```

는 출력 결과를 파일에 저장하라는 의미이다.

즉:

```text
echo 출력 결과
→ 파일에 기록
```

구조.

---

# 현재 실제 동작

```bash
echo "agent_api_key_test" > /home/agent-admin/agent-app/api_keys/t_secret.key
```

실행 시:

```text
t_secret.key 파일 생성
```

후:

```text
agent_api_key_test
```

문자열 저장.

---

# 현재 생성된 파일

```text
/home/agent-admin/agent-app/api_keys/t_secret.key
```

---

# 왜 api_keys 디렉토리에 저장했는가

현재 프로젝트에서:

```text
api_keys
```

는 민감 정보 저장 공간 역할이다.

즉:
- API Key
- Secret Token
- 인증 정보

등 저장 목적.

---

# 왜 키 파일을 따로 관리하는가

실제 서버 운영에서는:

```text
민감 정보를 코드 내부에 직접 작성하지 않음
```

구조가 일반적이다.

예:
- DB Password
- API Key
- AWS Secret Key

등.

---

# 코드에 직접 넣을 경우 문제점

예:

```python
API_KEY = "abcdefg"
```

처럼 코드에 직접 넣으면:

- GitHub 업로드 시 노출 가능
- 협업 중 유출 가능
- 로그/스크린샷 노출 가능

위험 존재.

---

# 실제 운영 방식

실제 서버에서는:
- 환경 변수
- 별도 설정 파일
- secret 파일

등으로 분리 관리한다.

현재 프로젝트의:

```text
t_secret.key
```

도 이런 구조를 단순화한 예시이다.

---

# chown 설정

```bash
chown agent-admin:agent-core /home/agent-admin/agent-app/api_keys/t_secret.key
```

의 의미:

```text
owner = agent-admin
group = agent-core
```

설정.

---

# 왜 agent-core 그룹인가

현재 프로젝트에서:

```text
agent-core
```

는 민감 정보 접근 가능한 그룹이다.

즉:
- 관리자
- 핵심 운영 사용자

만 접근 가능하도록 설계.

---

# chmod 660 의미

```bash
chmod 660 t_secret.key
```

의 의미:

```text
660 = rw- rw- ---
```

---

# 권한 구조 해석

| 대상 | 권한 |
|---|---|
| owner | read/write |
| group | read/write |
| others | 접근 불가 |

---

# 현재 권한 구조 의미

현재:

```text
owner = agent-admin
group = agent-core
permission = 660
```

상태.

즉:

| 사용자 | 접근 가능 여부 |
|---|---|
| agent-admin | 가능 |
| agent-core 그룹 사용자 | 가능 |
| 그 외 사용자 | 불가능 |

---

# 왜 execute(x) 권한이 없는가

현재 파일은:

```text
실행 파일이 아니라 데이터 파일
```

이다.

즉:
- 실행 목적 없음
- 읽기/쓰기만 필요

상태.

따라서:

```text
rw- rw- ---
```

만 부여.

---

# ls -l 명령어

```bash
ls -l
```

은 상세 파일 정보 출력 명령어.

---

# 출력 결과 해석

```text
-rw-rw---- 1 agent-admin agent-core 19 May 12 07:10 t_secret.key
```

---

# 첫 번째 문자

```text
-
```

의미:

```text
일반 파일
```

---

# rw-rw----

권한 의미.

```text
owner = rw-
group = rw-
others = ---
```

---

# agent-admin

파일 owner.

---

# agent-core

파일 group.

---

# 19

파일 크기(byte).

---

# cat 명령어

```bash
cat file
```

은 파일 내용을 출력하는 명령어.

현재:

```bash
cat /home/agent-admin/agent-app/api_keys/t_secret.key
```

실행 결과:

```text
agent_api_key_test
```

출력.

---

# 현재 프로젝트에서 이 단계의 목적

현재 단계는:

```text
민감 정보 저장 구조를
권한 기반으로 안전하게 관리
```

하는 연습이다.

즉:
- 파일 생성
- 권한 제한
- 그룹 기반 접근 제어

구조를 구현한 것이다.

---

# 현재 프로젝트 보안 구조 흐름

```text
api_keys 디렉토리 생성
        ↓
민감 파일 생성
        ↓
owner 설정
        ↓
group 제한
        ↓
others 접근 차단
```

---

# 현재 프로젝트 핵심 개념

현재 프로젝트는:

```text
민감 데이터는
일반 사용자에게 공개하지 않음
```

원칙을 적용한 구조이다.

즉:
- 공유 데이터
- 민감 데이터
- 운영 데이터

를 서로 다른 권한 정책으로 관리하였다.

# monitor.sh

현재 프로젝트의 핵심 자동화 스크립트.

```text
시스템 상태 점검
+
서버 모니터링
+
로그 기록
```

을 수행하는 Bash Script이다.

현재 프로젝트에서는:

```text
프로세스 상태
포트 상태
방화벽 상태
CPU
메모리
디스크
```

등을 자동 점검한다.

---

# nano로 monitor.sh 작성

```bash
nano /workspace/scripts/monitor.sh
```

## 의미

```text
nano 에디터로
monitor.sh 파일 생성 및 수정
```

---

# #!/bin/bash

```bash
#!/bin/bash
```

의미:

```text
이 파일을 bash shell로 실행
```

하겠다는 뜻.

---

# 환경 변수 설정

```bash
APP_NAME="agent-app"
PORT="15034"
LOG_FILE="/var/log/agent-app/monitor.log"
```

---

# APP_NAME

현재 감시할 프로세스 이름.

즉:

```text
agent-app 프로세스 존재 여부 확인
```

용도.

---

# PORT

현재 감시할 포트 번호.

즉:

```text
15034 포트 LISTEN 상태 확인
```

용도.

---

# LOG_FILE

모니터링 결과 저장 위치.

현재:

```text
/var/log/agent-app/monitor.log
```

사용.

---

# 날짜 생성

```bash
DATE=$(date '+%Y-%m-%d %H:%M:%S')
```

## 의미

현재 시간 문자열 생성.

예:

```text
2026-05-13 16:10:01
```

형태.

---

# $( ) 의미

```bash
$(command)
```

는:

```text
명령어 실행 결과를 변수에 저장
```

의미.

---

# 헤더 출력

```bash
echo "====== SYSTEM MONITOR RESULT ======"
```

## 의미

터미널 출력용 제목.

---

# Process Check

```bash
PID=$(pgrep -f "$APP_NAME")
```

## pgrep

프로세스 검색 명령어.

---

# -f 옵션

프로세스 전체 명령행 기준 검색.

즉:

```text
agent-app 문자열 포함 프로세스 검색
```

---

# PID 저장

검색된 프로세스 PID를:

```text
PID 변수에 저장
```

.

---

# if [ -z "$PID" ]

## 의미

```text
PID 값이 비어있는가?
```

즉:
- 프로세스 미실행 여부 확인.

---

# 프로세스 실패 처리

```bash
exit 1
```

의 의미:

```text
스크립트 비정상 종료
```

.

즉:
- Health Check 실패.

---

# Port Check

```bash
ss -tuln | grep -q ":$PORT "
```

---

# ss

네트워크 소켓 상태 확인 명령어.

---

# grep -q

검색 결과만 확인하고 출력은 생략.

---

# 의미

```text
15034 포트가 LISTEN 상태인지 확인
```

.

---

# 포트 실패 시

```bash
exit 1
```

실행.

즉:
- 서비스 비정상 판단.

---

# Firewall Check

```bash
if command -v ufw >/dev/null 2>&1;
```

---

# command -v

명령어 존재 여부 확인.

즉:

```text
ufw 설치 여부 확인
```

.

---

# >/dev/null 2>&1 의미

출력을 화면에 표시하지 않음.

즉:
- 조용히 검사.

---

# UFW 상태 확인

```bash
ufw status
```

를 통해:
- 방화벽 활성 여부 확인.

---

# WARNING만 출력하는 이유

과제 요구사항에서:

```text
방화벽 비활성은 경고만 출력
```

하도록 되어 있기 때문.

즉:
- 스크립트 종료는 하지 않음.

---

# Resource Monitoring

```bash
CPU_USAGE
MEM_USAGE
DISK_USAGE
```

변수 생성.

---

# CPU Usage

```bash
top -bn1
```

## top

실시간 시스템 자원 확인 명령어.

---

# -bn1 의미

| 옵션 | 의미 |
|---|---|
| -b | batch mode |
| -n1 | 1번만 출력 |

즉:
- 스크립트용 출력.

---

# awk

텍스트 처리 명령어.

현재 CPU idle 값을 이용해:

```text
실제 CPU 사용률 계산
```

수행.

---

# Memory Usage

```bash
free
```

명령 사용.

---

# free

메모리 상태 출력 명령어.

현재:

```text
사용 메모리 / 전체 메모리
```

비율 계산.

---

# Disk Usage

```bash
df /
```

## df

디스크 사용량 출력 명령어.

현재:

```text
Root 파티션(/)
```

기준 사용률 계산.

---

# Threshold Warning

```bash
CPU > 20
MEM > 10
DISK > 80
```

초과 여부 확인.

---

# CPU_INT=${CPU_USAGE%.*}

## 의미

소수점 제거.

예:

```text
25.3
→ 25
```

.

---

# 왜 정수 변환을 하는가

bash는:
- 실수 비교에 제한 존재.

따라서:
- threshold 비교 시 정수 사용.

---

# Warning 출력

예:

```text
[WARNING] CPU threshold exceeded
```

출력.

즉:
- 비정상 상태 감지.

---

# Log Append

```bash
>> "$LOG_FILE"
```

## >> 의미

파일 append.

즉:
- 기존 내용 유지
- 뒤에 추가 기록.

---

# 로그 형식

```text
[DATE] PID:... CPU:... MEM:... DISK_USED:...
```

형태 저장.

---

# 왜 로그를 저장하는가

운영 서버에서는:
- 상태 추적
- 장애 분석
- 운영 기록

이 중요하기 때문이다.

---

# Log Rotation

현재 프로젝트 요구사항:

```text
10MB 초과 시 rotate
최대 10개 유지
```

.

---

# FILE_SIZE_MB 계산

```bash
du -m
```

사용.

## du

파일/디렉토리 크기 확인 명령어.

---

# 10MB 초과 시

```bash
mv "$LOG_FILE" ...
```

실행.

즉:
- 기존 로그 이름 변경.

예:

```text
monitor_20260513_161000.log
```

형태 저장.

---

# touch "$LOG_FILE"

새 monitor.log 생성.

즉:
- 새 로그 기록 시작.

---

# ls -tp

로그 파일 정렬.

현재:
- 최신 로그 기준 정렬.

---

# tail -n +11

11번째 이후 로그 선택.

즉:
- 오래된 로그들 선택.

---

# xargs rm

선택된 오래된 로그 삭제.

즉:

```text
최대 10개 로그만 유지
```

구현.

---

# 현재 프로젝트 전체 monitor.sh 흐름

```text
monitor.sh 실행
        ↓
프로세스 확인
        ↓
포트 확인
        ↓
방화벽 확인
        ↓
CPU/MEM/DISK 수집
        ↓
Threshold 검사
        ↓
monitor.log 기록
        ↓
로그 용량 확인
        ↓
로그 rotate 수행
```

---

# 현재 프로젝트에서 monitor.sh의 의미

현재 프로젝트 핵심은:

```text
Linux 서버 운영 자동화
```

이다.

즉 monitor.sh는:

```text
서버 상태를 자동 점검하는
운영 자동화 스크립트
```

역할을 수행한다.

---

# 현재 프로젝트에서 학습한 핵심 개념

- Bash Script
- 프로세스 모니터링
- 포트 상태 점검
- Linux 자원 모니터링
- 로그 관리
- 시스템 자동화
- Health Check
- Threshold Monitoring
- Log Rotation
- 운영 서버 구조


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


# 로그 로테이션 코드가 필요한 이유

네 말이 맞다.

현재 코드가 정상적으로 계속 실행된다면:

```text
rotate된 로그 파일은 항상 최대 10개 이하로 유지된다
```

라고 보는 게 맞다.

그래서 이 코드는:

```text
로그가 10개를 넘은 뒤에 뒤늦게 처리하는 예외 코드
```

라기보다는,

```text
로그가 10개를 넘지 않도록 계속 유지하는 관리 코드
```

라고 이해하는 게 정확하다.

---

# 코드 흐름

```bash
if [ "$FILE_SIZE_MB" -ge 10 ]; then
    TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
    mv "$LOG_FILE" "/var/log/agent-app/monitor_${TIMESTAMP}.log"
    touch "$LOG_FILE"

    ls -tp /var/log/agent-app/monitor_*.log 2>/dev/null | tail -n +11 | xargs -r rm --

    echo "[INFO] Log rotated"
fi
```

이 코드는 `monitor.log`가 10MB 이상이 되었을 때만 실행된다.

---

# rotate가 발생하는 순간

예를 들어 현재 상태가 이렇다고 하자.

```text
monitor.log
monitor_1.log
monitor_2.log
...
monitor_10.log
```

여기서 `monitor.log`가 10MB 이상이 되면:

```bash
mv "$LOG_FILE" "/var/log/agent-app/monitor_${TIMESTAMP}.log"
```

에 의해 기존 `monitor.log`가 새로운 백업 로그로 이름이 바뀐다.

그러면 순간적으로 rotate된 로그 파일이 11개가 될 수 있다.

```text
monitor_새로운.log
monitor_1.log
monitor_2.log
...
monitor_10.log
```

즉 이 순간에는:

```text
rotate된 로그 파일이 10개를 초과
```

할 수 있다.

---

# 그래서 삭제 코드가 필요하다

이 코드:

```bash
ls -tp /var/log/agent-app/monitor_*.log 2>/dev/null | tail -n +11 | xargs -r rm --
```

는 방금 새로 생긴 로그까지 포함해서:

```text
최신 10개만 남기고
나머지 오래된 로그 삭제
```

를 수행한다.

즉 목적은:

```text
항상 10개 이하로 유지하기 위한 정리 작업
```

이다.

---

# 네가 말한 "항상 10개 이하로 유지되는 거 아니냐"에 대한 답

맞다.

그렇게 유지되도록 만드는 코드가 바로 이 부분이다.

```bash
ls -tp /var/log/agent-app/monitor_*.log 2>/dev/null | tail -n +11 | xargs -r rm --
```

즉 이 코드는:

```text
이미 10개 이하니까 필요 없는 코드
```

가 아니라,

```text
10개 이하 상태를 계속 유지하기 위해 필요한 코드
```

이다.

---

# 더 쉽게 비유하면

책장에 책을 최대 10권만 보관한다고 하자.

새 책이 들어올 때마다:

```text
책장에 새 책 추가
        ↓
책이 11권이 되었는지 확인
        ↓
11권이면 가장 오래된 책 버림
        ↓
다시 10권 유지
```

이 흐름이다.

현재 로그 로테이션도 똑같다.

```text
새 rotate 로그 생성
        ↓
rotate 로그가 11개 이상인지 확인
        ↓
오래된 로그 삭제
        ↓
최신 10개 유지
```

---

# 핵심 정리

이 코드는 에러 처리라기보다는:

```text
로그 보관 정책을 유지하기 위한 정상 관리 로직
```

이다.

현재 정책은:

```text
monitor.log가 10MB 이상이면 rotate
rotate된 로그는 최신 10개만 유지
그보다 오래된 로그는 삭제
```

이다.

즉:

```text
로그 파일 용량 관리
+
로그 파일 개수 관리
```

를 동시에 수행하는 코드이다.


# su - agent-admin

현재 프로젝트에서는:

```bash
su - agent-admin
```

명령어를 사용하여:

```text
root 계정
→ agent-admin 계정
```

으로 전환하였다.

---

# su 명령어

```bash
su
```

는:

```text
사용자 전환 명령어
```

이다.

즉:
- 현재 로그인 세션 안에서
- 다른 사용자 계정으로 변경.

---

# 현재 의미

```bash
su - agent-admin
```

의 의미:

```text
agent-admin 사용자 환경으로 로그인
```

.

---

# 왜 root에서 agent-admin으로 전환했는가

현재 프로젝트에서는:

```text
실제 운영 환경처럼
일반 사용자 계정 기반 작업
```

을 수행하기 위해 사용하였다.

즉:
- root 직접 사용 최소화
- 일반 사용자 기반 운영

구조 연습.

---

# - 옵션 의미

여기서 중요한 건:

```bash
su -
```

의:

```text
-
```

이다.

---

# su 와 su - 의 차이

## su agent-admin

사용자만 변경.

현재 shell 환경 일부 유지.

즉:
- 현재 PATH
- 현재 환경 변수
- 현재 작업 디렉토리

등 일부 유지 가능.

---

# su - agent-admin

완전한 로그인 환경 전환.

즉:
- HOME 변경
- PATH 변경
- shell 환경 변경
- 작업 디렉토리 변경

등 수행.

실제 로그인과 거의 동일한 상태.

---

# 현재 프로젝트에서는 왜 su - 를 사용했는가

현재 프로젝트 목표는:

```text
실제 사용자 환경 기반 운영
```

이다.

따라서:

```text
agent-admin 사용자로 실제 로그인한 것처럼
환경 전환
```

하기 위해:

```bash
su -
```

사용.

---

# 출력 결과 해석

전환 전:

```text
root@d3b412c69a10:/#
```

---

# 의미

| 부분 | 의미 |
|---|---|
| root | 현재 사용자 |
| d3b412c69a10 | 호스트명(컨테이너 ID 일부) |
| / | 현재 작업 디렉토리 |
| # | root 권한 shell |

---

# 전환 후

```text
agent-admin@d3b412c69a10:~$
```

---

# 의미

| 부분 | 의미 |
|---|---|
| agent-admin | 현재 사용자 |
| d3b412c69a10 | 호스트명 |
| ~ | 사용자 홈 디렉토리 |
| $ | 일반 사용자 shell |

---

# ~ 의미

```text
현재 사용자 홈 디렉토리
```

현재:

```text
/home/agent-admin
```

를 의미.

---

# # 와 $ 차이

## #

```text
root shell
```

의미.

즉:
- 최고 권한.

---

# $

```text
일반 사용자 shell
```

의미.

즉:
- 제한 권한 상태.

---

# 왜 일반 사용자 shell이 중요한가

실제 Linux 서버 운영에서는:

```text
일반 사용자 기반 운영
```

이 매우 중요하다.

즉:
- 보안 강화
- 실수 방지
- 권한 분리

목적.

---

# 현재 프로젝트에서의 역할

현재 프로젝트에서는:
- monitor.sh 실행
- cron 설정
- app 실행

등을:

```text
agent-admin 계정 기준
```

으로 수행하였다.

즉:
- 일반 사용자 기반 서버 운영 구조를 만든 것.

---

# Linux 권한 구조 관점

현재 프로젝트는:

```text
root
 → 시스템 전체 관리

agent-admin
 → 운영 관리자

agent-dev
 → 개발 사용자

agent-test
 → 테스트 사용자
```

구조를 연습한 것이다.

---

# 현재 프로젝트 전체 흐름

```text
root 계정으로 시스템 설정
        ↓
사용자 및 권한 구성
        ↓
su - agent-admin
        ↓
운영 사용자 환경 전환
        ↓
일반 사용자 기반 작업 수행
```

---

# 왜 root로 모든 걸 하지 않았는가

실제 서버에서는:
- 모든 작업을 root로 수행하지 않는다.

왜냐면:
- 실수 위험
- 보안 위험
- 권한 과다

문제가 있기 때문이다.

따라서:

```text
일반 사용자
+
필요 시 sudo
```

구조가 일반적이다.

---

# 현재 프로젝트 핵심 개념

현재 단계는:

```text
"Linux 서버 운영은
root가 아니라 일반 사용자 기반으로 수행"
```

한다는 구조를 학습하는 과정이다.


# 새 터미널에서 docker exec 실행

현재 프로젝트에서는:

```bash
docker exec -it codyssey-week1 bash
```

명령어를 사용하여:

```text
이미 실행 중인 컨테이너 내부에
새로운 bash 프로세스 접속
```

을 수행하였다.

---

# 왜 새 터미널을 열었는가

현재 프로젝트에서는 이미:

```text
첫 번째 터미널
```

에서:
- sshd 실행
- agent-app 실행
- 기타 작업

등을 수행 중이었다.

그 상태에서:
- 다른 상태 확인
- 포트 확인
- 프로세스 확인

등을 하기 위해:

```text
새로운 터미널 세션
```

을 연 것이다.

---

# docker exec 의미

```bash
docker exec
```

는:

```text
실행 중인 컨테이너 내부에서
새로운 프로세스 실행
```

명령어이다.

---

# 현재 명령어 의미

```bash
docker exec -it codyssey-week1 bash
```

의 의미:

```text
codyssey-week1 컨테이너 내부에
새로운 bash shell 실행
```

.

---

# 중요한 개념

이건:

```text
새 컨테이너 생성
```

이 아니다.

이미 실행 중인:

```text
codyssey-week1
```

컨테이너 안에:

```text
bash 프로세스 하나 추가 생성
```

하는 것이다.

---

# 현재 구조

```text
Container
 ├── bash (첫 번째 터미널)
 ├── sshd
 ├── cron
 ├── agent-app
 └── bash (docker exec로 새로 생성)
```

구조.

---

# -it 옵션 의미

## -i

interactive.

표준 입력 유지.

즉:
- 키보드 입력 가능.

---

# -t

tty 할당.

즉:
- 터미널 형태로 접속.

---

# bash

컨테이너 내부에서 실행할 프로그램.

현재:
- bash shell 실행.

---

# ss -tulnp 명령어

```bash
ss -tulnp
```

는 현재 열려 있는 네트워크 포트 확인 명령어.

---

# 옵션 의미

| 옵션 | 의미 |
|---|---|
| -t | TCP |
| -u | UDP |
| -l | LISTEN 상태 |
| -n | 숫자 형태 출력 |
| -p | 프로세스 정보 출력 |

---

# grep 15034

```bash
grep 15034
```

는:
- 15034 포트 관련 정보만 필터링.

---

# 출력 결과 해석

```text
tcp LISTEN 0 1 0.0.0.0:15034 0.0.0.0:*
```

의 의미:

| 항목 | 의미 |
|---|---|
| tcp | TCP 프로토콜 |
| LISTEN | 연결 대기 상태 |
| 0.0.0.0:15034 | 모든 인터페이스에서 15034 포트 사용 |
| 0.0.0.0:* | 외부 연결 허용 |

---

# LISTEN 의미

```text
현재 어떤 프로세스가
15034 포트에서 연결 대기 중
```

이라는 뜻.

즉:
- 서버 역할 수행 중.

---

# 0.0.0.0 의미

```text
모든 네트워크 인터페이스 허용
```

의미.

즉:
- localhost만 아니라
- 외부 네트워크 연결도 가능.

---

# 현재 프로젝트에서 15034 역할

현재 프로젝트에서는:

```text
agent-app 서비스 포트
```

역할로 사용.

즉:
- agent-app이 정상 실행 중인지 확인.

---

# 왜 이 확인이 중요한가

현재 프로젝트 요구사항 중:

```text
TCP 15034 LISTEN 상태 확인
```

이 존재한다.

즉:
- 서비스 정상 동작 여부 확인 목적.

---

# 현재 프로젝트 흐름

```text
agent-app 실행
        ↓
15034 포트 LISTEN
        ↓
ss -tulnp 로 확인
        ↓
서비스 정상 여부 검증
```

---

# 왜 새 터미널에서 확인했는가

첫 번째 터미널에서는:
- agent-app 실행 중
- 서비스 동작 중

상태였다.

현재 터미널을 그대로 사용하면:
- 실행 중인 프로세스 제어 문제
- shell 점유 문제

등이 생길 수 있다.

따라서:

```text
새 shell 세션에서 상태 점검
```

을 수행한 것이다.

---

# 현재 프로젝트 핵심 개념

현재 단계는:

```text
실행 중인 Linux 서버 상태를
다른 세션에서 점검
```

하는 구조를 학습하는 과정이다.

즉 실제 서버 운영처럼:
- 서비스 실행
- 다른 터미널에서 상태 점검

구조를 경험한 것이다.

# monitor.sh 배치

현재 프로젝트에서는 작성한 monitor.sh를 실제 운영 위치로 복사하였다.

```bash
cp /workspace/scripts/monitor.sh /home/agent-admin/agent-app/bin/monitor.sh
```

---

# cp 명령어

```bash
cp
```

는 파일 복사 명령어이다.

---

# 현재 의미

현재 작성한:

```text
/workspace/scripts/monitor.sh
```

파일을:

```text
/home/agent-admin/agent-app/bin/
```

으로 복사.

즉:

```text
실제 운영 위치에 배치
```

한 것이다.

---

# 왜 /workspace에서 작성했는가

현재 프로젝트에서:

```text
/workspace
```

는 Host와 Docker Container가 연결된 볼륨 영역이다.

즉:
- GitHub 관리 가능
- Host에서도 수정 가능
- 컨테이너 재생성 후에도 유지 가능

장점 존재.

---

# 왜 bin 디렉토리로 복사했는가

```text
/home/agent-admin/agent-app/bin
```

은:
- 실행 가능한 스크립트 저장 공간.

즉:
- 실제 운영용 shell script 위치.

---

# monitor.sh owner/group 설정

```bash
chown agent-dev:agent-core /home/agent-admin/agent-app/bin/monitor.sh
```

---

# 의미

```text
owner = agent-dev
group = agent-core
```

설정.

---

# 왜 agent-dev를 owner로 설정했는가

현재 프로젝트 구조에서는:

```text
agent-dev
```

를 개발 담당 사용자 역할로 사용하였다.

즉:
- monitor.sh 수정/관리 책임자 역할.

---

# 왜 agent-core 그룹인가

현재 프로젝트에서:

```text
agent-core
```

는 핵심 운영 그룹.

즉:
- 운영 관련 스크립트 접근 가능 그룹.

---

# chmod 750

```bash
chmod 750 /home/agent-admin/agent-app/bin/monitor.sh
```

---

# 의미

```text
750 = rwx r-x ---
```

---

# 권한 구조

| 대상 | 권한 |
|---|---|
| owner | rwx |
| group | r-x |
| others | --- |

---

# 현재 의미

## owner(agent-dev)

- 읽기 가능
- 수정 가능
- 실행 가능

---

## group(agent-core)

- 읽기 가능
- 실행 가능
- 수정 불가

---

## others

접근 불가.

---

# 왜 실행 권한(x)이 필요한가

monitor.sh는:

```text
실행 가능한 shell script
```

이기 때문이다.

즉:
- x 권한 없으면 실행 불가능.

---

# ls -l 결과 해석

```text
-rwxr-x--- 1 agent-dev agent-core ...
```

---

# 첫 번째 문자

```text
-
```

의미:

```text
일반 파일
```

.

---

# rwxr-x---

권한 구조.

```text
owner = rwx
group = r-x
others = ---
```

---

# agent-dev

파일 owner.

---

# agent-core

파일 group.

---

# bash -n 문법 검사

```bash
bash -n /home/agent-admin/agent-app/bin/monitor.sh
```

---

# 의미

```text
shell script 문법 검사
```

.

---

# 중요한 특징

```bash
bash -n
```

은:
- 실제 실행 안 함
- syntax만 검사.

즉:
- 괄호 오류
- if 오류
- fi 누락
- 문법 오류

등 확인 가능.

---

# 왜 출력이 없었는가

```text
오류가 없으면 아무것도 출력 안 함
```

이 정상.

즉:
- 문법 정상 상태.

---

# monitor.sh 실제 실행

```bash
/home/agent-admin/agent-app/bin/monitor.sh
```

---

# 실행 결과 의미

현재 monitor.sh가:
- 프로세스 상태
- 포트 상태
- 방화벽 상태
- CPU/MEM/DISK 상태

등을 점검.

---

# PID 여러 개 출력 문제

출력:

```text
PID: 4949
4950
5220
```

---

# 원인

```bash
pgrep -f "$APP_NAME"
```

가:
- 관련 프로세스를 여러 개 검색.

즉:
- 여러 PID 반환.

---

# 이후 수정

현재 프로젝트에서는:

```bash
head -n 1
```

추가하여:
- 첫 번째 PID만 출력하도록 수정.

---

# UFW 오류 발생 이유

출력:

```text
ERROR: problem running iptables
```

---

# 원인

Docker Container 내부에서는 기본적으로:
- kernel firewall 제어 권한 제한.

즉:
- iptables 접근 제한 가능.

---

# 왜 발생했는가

UFW는 내부적으로:

```text
iptables
```

를 사용한다.

하지만 일반 Docker Container는:
- host kernel firewall 직접 제어 불가.

---

# 그래서 privileged container 사용

현재 프로젝트 후반에서는:

```bash
--privileged
```

옵션으로 컨테이너 재생성.

즉:
- firewall 제어 허용.

---

# UFW Status... [WARNING]

현재 스크립트는:
- 방화벽 실패 시
- 종료하지 않고 WARNING만 출력.

---

# 이유

과제 요구사항에서:

```text
Firewall 비활성은 WARNING만 출력
```

하도록 요구했기 때문.

즉:
- Health Check 실패 대상 아님.

---

# CPU Usage : 100%

현재 순간 CPU 사용률.

---

# 왜 100%가 나왔는가

monitor.sh 실행 중:
- top
- awk
- shell processing

등 순간 CPU 사용 증가 가능.

또는:
- container idle 상태라
- 계산 순간 상대적으로 크게 측정 가능.

---

# Threshold Warning

현재 설정:

```text
CPU > 20%
```

초과.

따라서:

```text
[WARNING] CPU threshold exceeded
```

출력.

---

# monitor.log 기록 확인

```bash
tail -n 5 /var/log/agent-app/monitor.log
```

---

# tail 의미

파일 마지막 부분 출력.

---

# -n 5 의미

마지막 5줄 출력.

---

# 현재 의미

monitor.sh가 실제로:

```text
monitor.log에 기록 수행
```

했는지 확인.

---

# 로그 기록 성공

출력:

```text
[2026-05-13 ...]
```

형태 확인.

즉:
- append 정상 동작.

---

# UFW 포트 허용

```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
```

---

# 의미

## 20022

SSH 포트 허용.

---

## 15034

agent-app 서비스 포트 허용.

---

# ufw enable

```bash
ufw enable
```

의 의미:

```text
방화벽 활성화
```

.

---

# ufw status

현재 방화벽 상태 출력.

즉:
- 활성 여부
- 허용 포트

확인 가능.

---

# 현재 프로젝트의 핵심 의미

현재 단계는:

```text
운영 자동화 스크립트를
실제 Linux 서버 구조에 배치하고,
보안 정책 및 모니터링 체계를 연결
```

하는 과정이다.

즉:
- Linux 권한 관리
- Bash 자동화
- 서버 모니터링
- 로그 관리
- 방화벽 정책

등을 하나의 운영 구조로 연결한 단계.


# UFW 방화벽 설정

현재 프로젝트에서는 Ubuntu 방화벽(UFW)을 사용하여:

```text
허용할 포트만 열고
나머지는 차단
```

하는 보안 구조를 설정하였다.

---

# UFW란

UFW는:

```text
Uncomplicated Firewall
```

의 약자.

Ubuntu에서 사용하는 간단한 방화벽 관리 도구이다.

---

# 방화벽(Firewall)이란

방화벽은:

```text
들어오고 나가는 네트워크 연결을 제어
```

하는 보안 시스템이다.

즉:
- 허용된 포트만 접근 가능
- 나머지는 차단

하는 역할.

---

# 왜 방화벽이 필요한가

서버는 네트워크에 연결되어 있기 때문에:
- 외부 접속
- 스캔
- 공격

대상이 될 수 있다.

따라서:

```text
필요한 서비스만 공개
```

하는 것이 중요하다.

---

# 현재 프로젝트에서 허용한 포트

| 포트 | 역할 |
|---|---|
| 20022 | SSH |
| 15034 | agent-app |

---

# ufw allow 20022/tcp

```bash
ufw allow 20022/tcp
```

의 의미:

```text
TCP 20022 포트 접근 허용
```

.

---

# 왜 20022를 열었는가

현재 프로젝트에서:

```text
SSH 서버(sshd)
```

가:

```text
20022 포트
```

에서 동작 중이기 때문이다.

즉:
- SSH 접속 허용 목적.

---

# ufw allow 15034/tcp

```bash
ufw allow 15034/tcp
```

의 의미:

```text
15034 포트 접근 허용
```

.

---

# 왜 15034를 열었는가

현재 프로젝트에서:
- agent-app 서비스가
- 15034 포트 LISTEN

상태였기 때문.

즉:
- 외부 접근 가능하도록 허용.

---

# /tcp 의미

```text
TCP 프로토콜 기준 규칙
```

이라는 뜻.

현재 프로젝트 서비스들은:
- TCP 기반 서비스.

---

# ufw enable

```bash
ufw enable
```

의 의미:

```text
방화벽 활성화
```

.

즉:
- 설정한 규칙 적용 시작.

---

# Firewall is active

출력:

```text
Firewall is active and enabled on system startup
```

의 의미:

```text
방화벽 현재 활성 상태
+
부팅 시 자동 활성화
```

.

---

# ufw status

```bash
ufw status
```

는 현재 방화벽 규칙 확인 명령어.

---

# 출력 결과 해석

```text
Status: active
```

의 의미:

```text
현재 방화벽 활성 상태
```

.

---

# To

```text
허용 대상 포트
```

.

예:

```text
20022/tcp
```

---

# Action

```text
ALLOW
```

의 의미:

```text
접근 허용
```

.

---

# From

```text
Anywhere
```

의 의미:

```text
모든 IP에서 접근 허용
```

.

즉:
- 특정 IP 제한 없이 허용 상태.

---

# (v6) 의미

예:

```text
20022/tcp (v6)
```

.

---

# IPv6 의미

현재 규칙이:
- IPv4 뿐 아니라
- IPv6 에도 적용됨을 의미.

---

# IPv4 / IPv6 차이

## IPv4

예:

```text
192.168.0.1
```

.

현재 가장 일반적.

---

# IPv6

예:

```text
2001:db8::1
```

.

차세대 IP 체계.

---

# Rules updated

출력:

```text
Rules updated
```

의 의미:

```text
방화벽 규칙 정상 적용
```

.

---

# 현재 프로젝트에서의 의미

현재 구조:

```text
외부 접근 가능한 포트
```

를 최소화한 상태.

즉:
- SSH 포트
- 서비스 포트

만 허용.

---

# 왜 최소 포트만 열어야 하는가

열린 포트가 많을수록:
- 공격 표면 증가
- 불필요한 접근 증가
- 보안 위험 증가

한다.

따라서 실무 서버에서는:

```text
필요한 포트만 허용
```

원칙 사용.

---

# 현재 프로젝트 보안 구조

현재 프로젝트는:

```text
sshd → 20022
agent-app → 15034
```

만 외부 공개.

나머지는:
- 접근 차단 상태.

---

# 현재 프로젝트 전체 네트워크 흐름

```text
Mac Terminal
    ↓
20022
    ↓
sshd

또는

외부 요청
    ↓
15034
    ↓
agent-app
```

구조.

---

# 현재 프로젝트 핵심 개념

현재 단계는:

```text
Linux 서버에서
필요한 서비스만 외부에 공개
```

하는 보안 구조를 학습하는 과정이다.

즉:
- 네트워크 접근 제어
- 포트 기반 보안
- 최소 공개 정책

개념을 실제로 적용한 것이다.