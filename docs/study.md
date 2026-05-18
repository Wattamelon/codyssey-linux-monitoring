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


# cron

현재 프로젝트에서는 monitor.sh를 자동 반복 실행하기 위해:

```text
cron
```

을 사용하였다.

cron은 Linux의 대표적인 작업 스케줄러이다.

즉:

```text
정해진 시간마다
자동으로 명령 실행
```

가능하게 만드는 시스템.

---

# service cron start

```bash
service cron start
```

의 의미:

```text
cron 서비스 시작
```

.

---

# service 명령어

```bash
service
```

는 Linux 서비스(daemon)를 제어하는 명령어이다.

예:
- cron
- ssh
- nginx

등 실행/중지 가능.

---

# cron daemon

cron은:

```text
백그라운드에서 계속 실행되는 daemon
```

이다.

즉:
- 예약 시간 확인
- 예약 작업 실행

을 계속 반복.

---

# 출력 결과

```text
Starting periodic command scheduler cron
```

의 의미:

```text
cron 스케줄러 정상 시작
```

.

---

# crontab

```bash
crontab
```

은:
- cron 예약 작업 목록 관리 명령어.

---

# crontab -u agent-admin -e

```bash
crontab -u agent-admin -e
```

의 의미:

```text
agent-admin 사용자의 cron 예약 목록 수정
```

.

---

# -u 옵션

```text
특정 사용자 지정
```

.

현재:
- agent-admin 기준 cron 설정.

---

# -e 옵션

```text
edit
```

의미.

즉:
- cron 설정 파일 편집.

---

# 추가한 내용

```cron
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

---

# cron 문법 구조

```text
* * * * * command
│ │ │ │ │
│ │ │ │ └── 요일
│ │ │ └──── 월
│ │ └────── 날짜
│ └──────── 시간
└────────── 분
```

---

# 현재 의미

```cron
* * * * *
```

는:

```text
매 분마다
```

라는 뜻.

즉:

```text
1분마다 monitor.sh 실행
```

구조.

---

# 실제 흐름

```text
cron daemon 실행 중
        ↓
매 1분마다 시간 확인
        ↓
monitor.sh 실행
        ↓
monitor.log 기록
```

구조.

---

# 왜 자동화가 중요한가

실제 서버 운영에서는:

```text
사람이 직접 계속 상태 확인 불가능
```

하다.

따라서:
- 자동 모니터링
- 자동 백업
- 자동 로그 관리

등을 cron으로 수행.

---

# crontab -l

```bash
crontab -u agent-admin -l
```

의 의미:

```text
현재 등록된 cron 작업 목록 출력
```

.

---

# -l 옵션

```text
list
```

의미.

즉:
- 현재 예약 작업 확인.

---

# 출력 내용 해석

```cron
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

현재 등록 완료 상태.

즉:
- cron이 1분마다 monitor.sh 실행 예정.

---

# 주석(#) 부분 의미

출력된 긴 설명들은:

```text
cron 사용법 설명 주석
```

이다.

실제 동작하는 건:

```cron
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

한 줄.

---

# cron 작동 확인

```bash
tail -n 20 /var/log/agent-app/monitor.log
```

---

# tail 명령어

파일 마지막 부분 출력.

---

# -n 20

마지막 20줄 출력.

---

# 왜 monitor.log를 확인했는가

현재 핵심 목적은:

```text
cron이 실제로 monitor.sh를 자동 실행했는지 확인
```

하는 것.

---

# 로그 출력 의미

```text
[2026-05-13 15:52:07]
[2026-05-13 15:54:46]
[2026-05-13 16:09:01]
[2026-05-13 16:10:01]
```

등 시간별 로그가 계속 추가되고 있다.

즉:

```text
cron이 monitor.sh를 반복 실행 중
```

이라는 의미.

---

# append 구조

monitor.sh 내부:

```bash
>> "$LOG_FILE"
```

를 사용했기 때문에:
- 기존 로그 유지
- 새 로그 계속 추가

구조.

---

# PID 여러 줄 출력 문제

출력:

```text
PID:5051
5052
5638
5639
```

형태 발생.

---

# 원인

```bash
pgrep -f "$APP_NAME"
```

가:
- 여러 관련 프로세스를 반환.

즉:
- 여러 PID가 로그에 기록됨.

---

# 이후 수정

현재 프로젝트 후반에서는:

```bash
head -n 1
```

추가.

즉:
- 첫 번째 PID만 기록하도록 개선.

---

# 현재 프로젝트에서 cron의 의미

현재 단계는:

```text
서버 모니터링 자동화
```

를 구현한 단계이다.

즉:
- 사람이 직접 실행하지 않아도
- 시스템이 자동으로 상태 점검 수행.

---

# 실제 운영 서버에서 cron 활용 예시

실무에서는 cron으로:

- 로그 정리
- 백업
- 서버 점검
- DB dump
- 모니터링
- 메일 발송

등 자동화 수행.

---

# 현재 프로젝트 전체 흐름

```text
cron daemon 실행
        ↓
1분마다 monitor.sh 실행
        ↓
프로세스 상태 점검
        ↓
포트 상태 점검
        ↓
CPU/MEM/DISK 수집
        ↓
monitor.log 기록
```

---

# 현재 프로젝트 핵심 개념

현재 단계는:

```text
Linux 서버 운영 자동화 구조
```

를 학습하는 과정이다.

즉:
- 수동 운영
→ 자동 운영

구조로 발전시킨 것이다.

---

# crontab -u agent-admin -e 는 어떤 동작인가

```bash
crontab -u agent-admin -e
```

이 명령어는:

```text
agent-admin 사용자의 cron 예약 작업 목록을 편집
```

하는 명령어이다.

---

# 중요한 점

이건:

```text
현재 디렉토리에 있는 특정 파일을 직접 여는 명령
```

이 아니다.

즉:

```bash
/home/xxx/file
```

같은 파일 경로를 직접 여는 개념이 아님.

---

# 어디서 실행해도 동작하는 이유

예를 들어:

```bash
cd /
```

에서 실행해도 되고,

```bash
cd /tmp
```

에서 실행해도 되고,

```bash
cd /home
```

에서 실행해도 된다.

왜냐면:

```text
crontab 명령 자체가
시스템 내부 cron 설정 저장소를 관리
```

하기 때문이다.

즉:
- 현재 작업 디렉토리와 거의 무관.

---

# 실제로 수정되는 위치

실제로는 Linux 내부의:

```text
사용자별 cron 설정 저장 영역
```

이 수정된다.

Ubuntu/Debian 계열에서는 보통 내부적으로:

```text
/var/spool/cron/crontabs/
```

아래에 저장된다.

예:

```text
/var/spool/cron/crontabs/agent-admin
```

---

# 그런데 왜 직접 수정하지 않는가

이 파일들은:
- 권한 관리 중요
- 형식 검증 필요
- cron daemon 연동 필요

하기 때문에:

```text
직접 nano로 수정하지 않고
crontab 명령으로 관리
```

하는 것이 일반적이다.

---

# crontab -e 흐름

```bash
crontab -u agent-admin -e
```

실행 시 내부적으로:

```text
cron 저장소 읽기
        ↓
임시 편집 파일 생성
        ↓
nano/vim 실행
        ↓
수정 완료
        ↓
cron 형식 검사
        ↓
시스템 cron 저장소 반영
```

흐름으로 동작한다.

---

# 그래서 저장 후 이런 메시지가 나왔음

```text
crontab: installing new crontab
```

의 의미:

```text
수정한 cron 설정을
시스템에 반영 완료
```

라는 뜻.

---

# 현재 프로젝트에서 등록한 내용

```cron
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

이 설정은:

```text
agent-admin 사용자의 cron 작업
```

으로 저장된 것이다.

즉:
- cron daemon이
- agent-admin 권한으로
- monitor.sh 실행.

---

# 왜 -u 옵션을 사용했는가

현재 root 계정 상태에서:

```bash
crontab -u agent-admin -e
```

를 실행했기 때문이다.

즉:

```text
root가 agent-admin의 cron 설정 수정
```

하는 구조.

---

# 만약 agent-admin 로그인 상태였다면

이미:

```text
agent-admin 사용자 shell
```

상태였다면:

```bash
crontab -e
```

만 입력해도 된다.

왜냐면:
- 현재 사용자 기준으로 동작하기 때문.

---

# crontab과 일반 파일 편집의 차이

## 일반 nano 편집

```bash
nano file.txt
```

는:
- 특정 경로 파일 직접 수정.

---

# crontab -e

```bash
crontab -e
```

는:
- 시스템 cron 저장소 관리 명령.

즉:
- 내부 cron DB 수정에 가까운 개념.

---

# 현재 프로젝트에서 cron 구조

```text
crontab 설정 저장
        ↓
cron daemon이 주기 확인
        ↓
예약 시간 도달
        ↓
monitor.sh 자동 실행
        ↓
monitor.log 기록
```

---

# 현재 프로젝트 핵심 개념

현재 단계는:

```text
Linux 시스템의 예약 작업 관리 구조
```

를 학습하는 과정이다.

즉:
- 특정 파일 실행이 아니라
- 시스템 스케줄러 등록

개념에 가깝다.

---

# getfacl 과 ls -l 의 차이

현재 프로젝트에서:

```bash
getfacl /home/agent-admin/agent-app/upload_files
```

를 실행했을 때:

```text
# owner: agent-admin
# group: agent-common
user::rwx
group::rwx
other::---
```

출력되었다.

---

# 그런데 왜 ls -l 과 비슷해 보이는가

맞다.

현재 설정에서는:

```text
기본 Linux 권한(owner/group/others)
```

만 사용했기 때문에:

```bash
ls -l
```

과 거의 비슷한 정보처럼 보인다.

예:

```bash
ls -ld upload_files
```

출력:

```text
drwxrwx--- ...
```

도 결국:
- owner
- group
- rwx

정보를 보여준다.

즉 현재 프로젝트 상태에서는:

```text
ACL 추가 설정을 안 했기 때문에
출력이 거의 비슷하게 보이는 것
```

이다.

---

# 그럼 getfacl은 왜 존재하는가

핵심은:

```text
ACL은 기본 Linux 권한보다
더 세밀한 권한 설정 가능
```

하다는 점이다.

현재는:
- owner
- group
- others

만 존재해서 차이가 거의 안 보이는 것.

---

# 기본 Linux 권한 구조 한계

일반 Linux 권한은:

```text
owner
group
others
```

3단계만 존재한다.

즉:

```text
특정 사용자 한 명만 추가 허용
```

같은 세밀한 제어가 어렵다.

---

# 예시 문제 상황

예를 들어:

```text
owner = agent-admin
group = agent-common
```

상태라고 하자.

그런데:

```text
agent-test만 접근 막고 싶다
```

거나,

```text
agent-dev만 추가 쓰기 권한 주고 싶다
```

같은 상황 발생 가능.

---

# 기본 chmod/chown만으로 어려움

기본 권한 시스템에서는:
- group 전체 허용
- group 전체 차단

정도만 가능.

즉:
- 사용자 개별 제어 어려움.

---

# ACL의 진짜 역할

ACL은:

```text
특정 사용자별
세밀한 권한 추가 가능
```

하다.

---

# 예시 ACL 추가

예:

```bash
setfacl -m u:agent-test:r-- file.txt
```

의 의미:

```text
agent-test 사용자에게만
읽기 권한 추가
```

.

---

# 이 경우 getfacl 결과

```text
user::rw-
user:agent-test:r--
group::---
other::---
```

처럼 추가 정보가 나타난다.

---

# 그런데 ls -l 은?

이런 ACL 세부 정보는:

```bash
ls -l
```

만으로는 완전히 표현 불가능하다.

---

# ls -l 의 한계

ls -l 은:

```text
기본 rwx 구조만 단순 출력
```

한다.

즉:
- owner
- group
- others

만 보여줌.

---

# ACL 존재 시 ls -l 변화

ACL이 추가되면:

```text
-rwxrwx---+
```

처럼:

```text
+
```

표시가 붙는다.

---

# + 의미

```text
추가 ACL 존재
```

의미.

하지만:
- 어떤 사용자에게
- 어떤 권한이 있는지는

ls -l만으로는 안 보인다.

---

# 그래서 getfacl 사용

ACL 세부 정보는:

```bash
getfacl
```

로 확인해야 한다.

즉:
- 사용자별 권한
- 추가 그룹 권한
- 세부 ACL 정책

등 확인 가능.

---

# 현재 프로젝트에서는 왜 차이가 안 보였는가

현재 프로젝트에서는:

```text
추가 ACL 설정(setfacl)
```

을 하지 않았다.

즉:
- 기본 owner/group/others 구조만 존재.

그래서:

```text
ls -l 과 거의 비슷한 출력
```

처럼 보이는 것이다.

---

# 현재 프로젝트에서 getfacl 사용 이유

현재 단계의 목적은:

```text
권한 구조 검증
```

이다.

즉:
- owner 확인
- group 확인
- rwx 확인

목적.

그리고 동시에:

```text
ACL 기반 권한 관리 도구 존재 학습
```

의 의미도 있다.

---

# 현재 프로젝트 핵심 개념

현재 프로젝트는 아직:

```text
기본 Linux 권한 모델
```

위주로 사용하였다.

하지만 실제 서버 운영에서는:
- ACL
- 사용자별 접근 제어
- 세밀한 권한 관리

등이 자주 사용된다.

즉 getfacl은:

```text
고급 권한 관리 확인 도구
```

라고 이해하는 게 중요하다.

---

# 현재 상태 요약

현재 프로젝트 상태:

```text
ACL 추가 설정 없음
→ getfacl 과 ls -l 이 거의 비슷해 보임
```

하지만 실제로 ACL을 사용하기 시작하면:

```text
getfacl 이 훨씬 더 자세한 권한 정보 제공
```

하게 된다.
---

# 환경 변수(Environment Variable)

현재 프로젝트에서는:

```bash
export AGENT_HOME=/home/agent-admin/agent-app
```

같은 명령어를 사용하여 환경 변수를 설정하였다.

---

# 환경 변수란

환경 변수(Environment Variable)는:

```text
Linux Shell 안에서 사용하는
전역 변수
```

이다.

즉:
- 경로
- 설정값
- 포트 번호
- 실행 환경 정보

등을 저장하는 변수.

---

# export 의미

```bash
export 변수명=값
```

의 의미:

```text
현재 shell 환경에 변수 등록
```

하는 것.

---

# 현재 예시

```bash
export AGENT_HOME=/home/agent-admin/agent-app
```

의 의미:

```text
AGENT_HOME 변수에
/home/agent-admin/agent-app 저장
```

.

---

# export 하면 실제로 무슨 일이 일어나는가

현재 shell 프로세스 내부에:

```text
AGENT_HOME
```

이라는 환경 변수가 등록된다.

즉 shell 메모리 내부에:

```text
AGENT_HOME=/home/agent-admin/agent-app
```

정보 저장.

---

# 이후 어떻게 사용하는가

이후 shell에서는:

```bash
$AGENT_HOME
```

으로 참조 가능.

예:

```bash
echo $AGENT_HOME
```

출력:

```text
/home/agent-admin/agent-app
```

.

---

# 왜 $를 붙이는가

Linux shell에서:

```bash
$변수명
```

은:

```text
변수 값 가져오기
```

의미.

---

# 현재 프로젝트에서 설정한 환경 변수들

## AGENT_HOME

```bash
export AGENT_HOME=/home/agent-admin/agent-app
```

애플리케이션 루트 디렉토리.

---

# AGENT_PORT

```bash
export AGENT_PORT=15034
```

서비스 포트 번호.

---

# AGENT_UPLOAD_DIR

```bash
export AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files
```

업로드 디렉토리 경로.

---

# 여기서 중요한 점

```bash
$AGENT_HOME
```

를 재사용했다.

즉:

```text
변수를 이용해 다른 변수 생성
```

가능.

---

# 실제 결과

현재:

```text
AGENT_HOME=/home/agent-admin/agent-app
```

이므로:

```text
AGENT_UPLOAD_DIR
=
/home/agent-admin/agent-app/upload_files
```

가 된다.

---

# AGENT_KEY_PATH

```bash
export AGENT_KEY_PATH=$AGENT_HOME/api_keys/t_secret.key
```

Secret Key 파일 위치 저장.

---

# AGENT_LOG_DIR

```bash
export AGENT_LOG_DIR=/var/log/agent-app
```

로그 디렉토리 위치 저장.

---

# echo 로 확인

```bash
echo $AGENT_HOME
```

의 의미:

```text
환경 변수 값 출력
```

.

---

# 왜 환경 변수를 사용하는가

현재 프로젝트 핵심은:

```text
경로 하드코딩 방지
```

이다.

---

# 하드코딩 문제

예를 들어 코드 곳곳에:

```bash
/home/agent-admin/agent-app
```

를 직접 반복 작성하면:

- 경로 변경 어려움
- 유지보수 어려움
- 재사용 어려움

문제 발생.

---

# 환경 변수 사용 장점

예:

```bash
$AGENT_HOME
```

를 사용하면:

- 경로 변경 쉬움
- 코드 재사용 가능
- 환경 이동 쉬움

장점 존재.

---

# 실제 운영 서버에서 환경 변수 활용 예시

실무에서는:
- DB 주소
- API Key
- PORT
- SECRET
- ENV 설정

등을 환경 변수로 관리하는 경우 많다.

예:

```bash
export DB_HOST=localhost
export DB_PORT=3306
```

.

---

# 환경 변수는 어디까지 유지되는가

중요한 점:

```text
현재 shell 세션까지만 유지
```

된다.

즉 터미널 종료하면 사라진다.

---

# 왜 사라지는가

현재 export는:

```text
현재 shell 프로세스 메모리
```

에만 등록되기 때문이다.

---

# 영구 저장하려면?

보통:

```text
~/.bashrc
~/.profile
/etc/environment
```

등에 저장.

---

# 현재 프로젝트에서는 왜 export만 사용했는가

현재 목적은:

```text
환경 변수 개념 학습
```

이기 때문이다.

즉:
- shell 변수
- 환경 변수 참조
- 경로 재사용

개념 이해 목적.

---

# 키 파일 생성 부분 설명

```bash
echo "agent_api_key_test" > /home/agent-admin/agent-app/api_keys/t_secret.key
```

---

# 의미

```text
t_secret.key 파일 생성
+
문자열 저장
```

.

---

# 현재 프로젝트에서 역할

현재 프로젝트에서는:
- 실제 인증 사용 목적 X
- 보안 파일 관리 구조 연습 목적.

---

# chown 설정

```bash
chown agent-admin:agent-core t_secret.key
```

의 의미:

```text
owner = agent-admin
group = agent-core
```

설정.

---

# chmod 660

```bash
chmod 660 t_secret.key
```

의 의미:

```text
rw- rw- ---
```

.

즉:
- owner 읽기/쓰기 가능
- group 읽기/쓰기 가능
- others 접근 불가.

---

# ls -l 결과 해석

```text
-rw-rw---- 1 agent-admin agent-core ...
```

---

# 의미

| 부분 | 의미 |
|---|---|
| - | 일반 파일 |
| rw-rw---- | 권한 |
| agent-admin | owner |
| agent-core | group |

---

# 현재 프로젝트 전체 흐름

```text
환경 변수 설정
        ↓
경로/포트/로그 위치 관리
        ↓
Secret Key 파일 생성
        ↓
권한 제한
        ↓
민감 정보 보호 구조 구성
```

---

# 현재 프로젝트 핵심 개념

현재 단계는:

```text
실행 환경 정보를
환경 변수로 관리
```

하는 구조와,

```text
민감 정보 파일을
권한 기반으로 보호
```

하는 구조를 학습하는 과정이다.

즉:
- Linux 환경 변수
- Shell 변수 참조
- 운영 환경 구성
- Secret 관리 기초

개념을 실제로 경험한 단계이다.
---

````md id="n5v8qx"
# 리다이렉션(Redirection)

Linux Shell에서는:

```text
명령어 출력 결과를
파일로 보내는 기능
```

을 리다이렉션이라고 한다.

대표적으로:

```bash
>
>>
```

를 많이 사용한다.

---

# > 의미

```bash
>
```

는:

```text
출력 결과를 파일에 새로 덮어쓰기
```

의미이다.

---

# 예시

```bash
echo "hello" > test.txt
```

실행 시:

```text
test.txt 파일 생성
```

후:

```text
hello
```

저장.

---

# 이미 파일이 존재한다면?

예:

현재 test.txt 내용:

```text
abc
```

상태에서:

```bash
echo "hello" > test.txt
```

실행하면:

```text
기존 내용 삭제
```

후:

```text
hello
```

만 남는다.

즉:

```text
파일 내용을 새로 덮어씀
```

.

---

# >> 의미

```bash
>>
```

는:

```text
출력 결과를 파일 맨 뒤에 추가(Append)
```

의미이다.

---

# 예시

현재 test.txt:

```text
abc
```

상태에서:

```bash
echo "hello" >> test.txt
```

실행 시 결과:

```text
abc
hello
```

즉:
- 기존 내용 유지
- 뒤에 새 내용 추가.

---

# 현재 프로젝트 monitor.sh에서 사용한 코드

```bash
echo "[$DATE] PID:$PID CPU:${CPU_USAGE}% ..." >> "$LOG_FILE"
```

---

# 왜 >>를 사용했는가

현재 목적은:

```text
모니터링 기록을 계속 누적 저장
```

하는 것이기 때문이다.

즉:
- 이전 기록 유지
- 새 상태 계속 추가

구조 필요.

---

# 만약 > 를 사용했다면?

예:

```bash
echo "..." > "$LOG_FILE"
```

를 사용했다면:

```text
매 실행마다 기존 로그 삭제
```

된다.

즉:
- 마지막 기록만 남음.

---

# 실제 문제 상황

cron이:
- 1분마다 monitor.sh 실행

중이었다.

만약:

```bash
>
```

사용 시:

```text
매 1분마다 monitor.log 전체 덮어쓰기
```

발생.

즉:
- 과거 로그 전부 사라짐.

---

# 왜 로그는 누적되어야 하는가

운영 서버에서 로그는:

```text
과거 상태 추적
```

목적이 매우 중요하다.

예:
- 장애 발생 시간
- CPU 급증 시점
- 메모리 부족 시점
- 서비스 다운 시점

등 확인 가능해야 한다.

---

# 로그의 핵심 역할

로그는:

```text
운영 기록(history)
```

이다.

즉:
- 현재 상태만 중요한 게 아니라
- 시간 흐름 기록이 중요.

---

# 현재 프로젝트 예시

현재 monitor.log:

```text
[16:09]
CPU:1.6%

[16:10]
CPU:17.5%

[16:11]
CPU:100%
```

형태로 계속 누적됨.

즉:
- 시스템 상태 변화 추적 가능.

---

# 만약 > 를 사용했다면

결과:

```text
[16:11]
CPU:100%
```

만 남는다.

즉:
- 이전 기록 전부 삭제.

---

# 그래서 운영 로그는 대부분 >> 사용

실제 Linux 서버에서도:
- application log
- access log
- monitoring log

등 대부분:

```text
append(>>)
```

방식 사용.

---

# 현재 프로젝트에서 >> 가 중요한 이유

현재 monitor.sh는:

```text
주기적 상태 기록 시스템
```

이다.

즉:
- cron이 반복 실행
- 상태 계속 기록

구조.

따라서:

```text
기존 로그 유지
+
새 로그 추가
```

가 필수.

---

# 현재 프로젝트 로그 흐름

```text
cron 실행
        ↓
monitor.sh 실행
        ↓
현재 상태 수집
        ↓
monitor.log 뒤에 추가 기록
        ↓
운영 기록 누적
```

---

# > 와 >> 핵심 차이

| 기호 | 의미 |
|---|---|
| > | 덮어쓰기(overwrite) |
| >> | 뒤에 추가(append) |

---

# 현재 프로젝트 핵심 개념

현재 단계는:

```text
운영 서버 로그는
시간 흐름에 따라 누적 관리
```

된다는 구조를 학습하는 과정이다.

즉:
- 상태 기록
- 장애 추적
- 운영 이력 관리

를 위해:

```text
append 방식(>>)
```

이 필요하다는 개념을 이해하는 것이 핵심이다.
````


---
# 과제목표
---
# SSH 포트 변경과 Root 원격 접속 차단이 왜 기본 보안인가

기본 SSH 포트는:

```text
22
```

이다.

하지만 22번 포트는:
- 자동 포트 스캔
- 브루트포스 공격
- 무차별 로그인 시도

등의 주요 공격 대상이 된다.

따라서 실제 서버 운영에서는:

```text
비표준 포트 사용
```

을 통해:
- 단순 자동 공격 감소
- 기본 스캔 감소

효과를 얻는다.

현재 프로젝트에서는:

```text
20022
```

포트를 사용하였다.

---

Root 원격 접속 차단은:

```text
최고 권한 계정 직접 노출 방지
```

목적이다.

Root 계정은:
- 모든 파일 접근 가능
- 시스템 전체 제어 가능

상태이다.

따라서:
- 계정 탈취 시 위험 매우 큼
- 실수 발생 시 피해 큼

문제가 존재한다.

그래서 실제 서버에서는:

```text
일반 사용자 로그인
→ 필요 시 sudo 사용
```

구조를 사용한다.

현재 프로젝트에서는:

```text
PermitRootLogin no
```

설정을 통해 Root SSH 로그인을 차단하였다.

---

# UFW를 사용해 “필요 포트만 허용”하는 이유

방화벽(Firewall)은:

```text
네트워크 접근 제어 시스템
```

이다.

즉:
- 허용된 포트만 공개
- 나머지 포트는 차단

하는 역할을 수행한다.

현재 프로젝트에서는:

```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
```

설정을 통해:
- SSH 포트
- agent-app 포트

만 허용하였다.

---

필요한 포트만 열어야 하는 이유는:

```text
공격 표면 최소화
```

때문이다.

열린 포트가 많을수록:
- 공격 가능성 증가
- 불필요한 서비스 노출
- 취약점 노출 가능성 증가

문제가 발생한다.

따라서 실제 서버 운영에서는:

```text
필요 최소 포트만 허용
```

원칙을 사용한다.

---

검증은:

```bash
ufw status
```

명령을 통해 수행하였다.

즉:
- 방화벽 활성 여부
- 허용 포트 목록

확인 가능.

---

# 역할 기반 계정/그룹과 ACL을 통해 공유 디렉토리와 보안 디렉토리를 분리하는 이유

현재 프로젝트에서는:
- agent-admin
- agent-dev
- agent-test

사용자를 생성하였다.

또한:
- agent-common
- agent-core

그룹을 구성하였다.

---

공유 디렉토리:

```text
upload_files
```

는:
- 여러 사용자가 협업 가능하도록
- agent-common 그룹 접근 허용

구조로 설계하였다.

반면:

```text
api_keys
```

는:
- API Key
- Secret Token

등 민감 정보를 저장하는 공간이다.

따라서:
- agent-core 그룹만 접근 가능하도록 제한하였다.

---

즉 현재 프로젝트 핵심은:

```text
데이터 중요도에 따라
접근 권한을 분리
```

한 것이다.

---

ACL 및 Linux 권한 구조를 사용하는 이유는:

```text
최소 권한 원칙
```

을 적용하기 위함이다.

즉:
- 필요한 사용자만 접근 허용
- 불필요한 접근 차단

구조를 만든 것이다.

---

# 환경 변수(AGENT_HOME 등)로 실행 환경을 고정하는 이유

환경 변수(Environment Variable)는:

```text
프로그램 실행 환경 정보를 저장하는 변수
```

이다.

예:

```bash
AGENT_HOME=/home/agent-admin/agent-app
```

---

환경 변수를 사용하는 이유는:

```text
경로 하드코딩 방지
```

때문이다.

예를 들어 코드에:

```bash
/home/agent-admin/agent-app
```

를 직접 반복 작성하면:
- 환경 변경 시 수정 어려움
- 유지보수 어려움

문제가 발생한다.

---

반면:

```bash
$AGENT_HOME
```

를 사용하면:
- 경로 변경 시 변수만 수정
- 스크립트 재사용 가능
- 환경 이동 쉬움

장점 존재.

---

환경 변수 검증은:

```bash
echo $AGENT_HOME
```

등으로 수행 가능하다.

---

# 쉘 스크립트로 프로세스/포트/리소스 상태를 수집하고 로그로 남기는 이유

현재 프로젝트의 monitor.sh는:

- 프로세스 상태
- 포트 상태
- CPU 사용률
- 메모리 사용률
- 디스크 사용률

등을 자동 수집하였다.

---

프로세스 상태 확인 이유:

```text
서비스가 정상 실행 중인지 확인
```

하기 위함.

현재 프로젝트에서는:

```bash
pgrep -f
```

를 사용하였다.

---

포트 상태 확인 이유:

```text
서비스가 실제 네트워크 연결을 받고 있는지 확인
```

하기 위함.

현재 프로젝트에서는:

```bash
ss -tuln
```

명령을 사용하였다.

---

리소스 상태 수집 이유:

```text
시스템 과부하 감지
```

를 위함.

예:
- CPU 과다 사용
- 메모리 부족
- 디스크 부족

등 감지 가능.

---

로그를 남기는 이유는:

```text
운영 기록 추적
```

목적이다.

즉:
- 장애 분석
- 문제 추적
- 상태 이력 확인

가능.

현재 프로젝트에서는:

```text
/var/log/agent-app/monitor.log
```

에 기록하였다.

---

# crontab으로 모니터링을 주기 실행하는 이유

cron은 Linux 작업 스케줄러이다.

즉:

```text
정해진 시간마다 자동 실행
```

가능하게 만든다.

현재 프로젝트에서는:

```cron
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

를 사용하여:
- 1분마다 monitor.sh 실행

구조를 만들었다.

---

자동 실행이 필요한 이유는:

```text
사람이 직접 계속 서버 상태를 확인할 수 없기 때문
```

이다.

실제 서버 운영에서는:
- 자동 모니터링
- 자동 백업
- 자동 로그 관리

등을 cron으로 수행한다.

---

# 로그 보존 정책(압축/삭제)이 필요한 이유

로그는 시간이 지나면 계속 증가한다.

만약 제한 없이 누적되면:

```text
디스크 용량 부족
```

문제가 발생 가능하다.

따라서 실제 운영 서버에서는:

- 로그 rotate
- 오래된 로그 삭제
- 압축 저장

등을 수행한다.

---

현재 프로젝트에서는:
- 10MB 초과 시 rotate
- 최신 10개 로그만 유지

구조를 구현하였다.

즉:

```text
운영 기록은 유지하되
무한 증가하지 않도록 관리
```

하는 구조를 만든 것이다.

---

# 현재 프로젝트 전체 핵심 흐름

```text
Linux 서버 구성
        ↓
사용자/권한 분리
        ↓
방화벽 설정
        ↓
서비스 실행
        ↓
monitor.sh 상태 점검
        ↓
monitor.log 기록
        ↓
cron 자동화
        ↓
로그 rotate 및 보존 관리
```

즉 현재 프로젝트는:

```text
Linux 기반 서버 운영 및 보안 자동화 구조
```

를 직접 구성하고 실습하는 과정이다.


---
# 평가항목
---

# SSH 포트가 20022로 변경되었고, Root 원격 접속이 차단되었는가?

기본 SSH 포트는 22번이다.

하지만 22번 포트는:
- 자동 포트 스캔
- 브루트포스 공격
- 무차별 로그인 시도

등의 주요 공격 대상이 된다.

따라서 실제 서버에서는:
- 비표준 포트 사용
- Root 직접 로그인 차단

을 기본 보안으로 많이 사용한다.

현재 프로젝트에서는:

```text
Port 20022
PermitRootLogin no
```

설정을 적용하였다.

즉:
- SSH 포트를 20022로 변경
- Root 원격 로그인 차단

구조를 구성하였다.

---

# 방화벽이 활성화되어 있고, 20022/tcp와 15034/tcp만 허용되는가?

방화벽은:

```text
네트워크 접근 제어 시스템
```

이다.

현재 프로젝트에서는 UFW를 사용하였다.

설정:

```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
ufw enable
```

현재 허용된 포트는:
- 20022 → SSH
- 15034 → agent-app

뿐이다.

즉:
- 필요한 서비스만 외부 공개
- 나머지 포트 차단

구조를 만들었다.

---

# agent-admin/dev/test 계정과 agent-common/core 그룹이 요구사항대로 구성되어 있는가?

현재 프로젝트에서는:

```text
agent-admin
agent-dev
agent-test
```

사용자를 생성하였다.

또한:

```text
agent-common
agent-core
```

그룹을 생성하였다.

구조는 다음과 같다.

## agent-common

- agent-admin
- agent-dev
- agent-test

포함.

즉:
- 공유 디렉토리 접근 그룹.

---

## agent-core

- agent-admin
- agent-dev

포함.

즉:
- 민감 정보 접근 가능 그룹.

---

현재 구조는:

```text
역할 기반 권한 관리(RBAC)
```

구조를 구현한 것이다.

---

# 앱이 Boot Sequence 5단계 [OK]를 통과하고 “Agent READY”가 출력되는가?

현재 프로젝트에서는:
- app 실행
- 프로세스 확인
- 포트 확인

등을 수행하였다.

Boot Sequence는:

```text
애플리케이션 초기화 단계
```

이다.

보통:
- 설정 로딩
- 디렉토리 확인
- 포트 bind
- 로그 초기화
- 서비스 시작

등을 수행한다.

최종적으로:

```text
Agent READY
```

출력이 나오면:
- 애플리케이션 초기화 완료
- 서비스 준비 완료

상태를 의미한다.

---

# monitor.sh가 프로세스/포트 상태를 점검하고, 비정상 상태에서 exit 1로 종료되는가?

현재 monitor.sh는:

```bash
pgrep -f
```

로 프로세스를 확인하고,

```bash
ss -tuln
```

으로 포트 LISTEN 상태를 확인한다.

예:

```bash
if [ -z "$PID" ]; then
    exit 1
fi
```

처럼:
- 프로세스 없음
- 포트 미오픈

상황 발생 시:

```text
exit 1
```

로 종료한다.

즉:
- Health Check 실패
- 비정상 상태 감지

구조를 구현하였다.

---

# /var/log/agent-app/monitor.log가 지정 포맷으로 누적 기록되는가?

현재 monitor.sh는:

```bash
>> "$LOG_FILE"
```

를 사용하여 로그를 append 방식으로 기록한다.

예:

```text
[2026-05-13 16:10:01] PID:5051 CPU:17.5% MEM:5.4% DISK_USED:1%
```

형태로 저장된다.

즉:
- 기존 로그 유지
- 새 로그 뒤에 추가

구조.

---

# cron 매분 실행으로 monitor.log가 자동 증가하는가?

현재 프로젝트에서는:

```cron
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

를 등록하였다.

즉:
- 매 1분마다 monitor.sh 실행.

따라서:

```text
monitor.log가 계속 자동 증가
```

하게 된다.

실제 확인은:

```bash
tail -n 20 /var/log/agent-app/monitor.log
```

로 수행하였다.

---

# monitor.log 용량 관리(10MB/10개)가 설정되어 있고 동작을 설명할 수 있는가?

현재 monitor.sh는:

```bash
if [ "$FILE_SIZE_MB" -ge 10 ]
```

조건으로:
- monitor.log가 10MB 이상이면 rotate 수행.

기존 로그를:

```text
monitor_YYYYMMDD_HHMMSS.log
```

형태로 변경하고,
새 monitor.log를 생성한다.

또한:

```bash
tail -n +11 | xargs rm
```

를 통해:
- 최신 10개 로그만 유지
- 오래된 로그 삭제

구조를 구현하였다.

즉:
- 로그 무한 증가 방지
- 디스크 용량 관리

구조를 만든 것이다.

---

# 프로세스는 살아있는데 포트가 안 열리는 상황”을 발견했다면, 원인 후보와 확인 순서를 설명할 수 있는가?

현재 프로젝트 기준으로:

```bash
pgrep -f agent-app
```

에서는 PID가 나오지만,

```bash
ss -tulnp | grep 15034
```

에서는 아무것도 안 보이는 상황이다.

즉:
- 프로세스는 존재
- 실제 서비스 포트는 안 열림

상태.

---

가능한 원인:

- 포트 bind 코드 없음
- 포트 충돌
- localhost만 bind
- Docker publish 누락
- 권한 문제
- bind 실패
- 설정 오류

등.

---

확인 순서:

```text
프로세스 확인
        ↓
포트 LISTEN 확인
        ↓
bind 주소 확인
        ↓
포트 충돌 확인
        ↓
로그 확인
        ↓
Docker publish 확인
        ↓
방화벽 확인
```

순서로 접근한다.

---

# 모니터링 대상이 웹 서버(Nginx 등)로 바뀐다면, monitor.sh에서 바꿔야 할 핵심 포인트(프로세스/포트/로그/임계값)를 설명할 수 있는가?

현재 monitor.sh는:
- agent-app
- 15034 포트

기준이다.

Nginx 기준으로 변경 시:

## 프로세스

```bash
APP_NAME="nginx"
```

---

## 포트

```bash
80
443
```

확인 필요.

---

## 로그 경로

예:

```bash
/var/log/nginx-monitor/monitor.log
```

등으로 변경 가능.

---

## 임계값

웹 서버는:
- 트래픽 증가 가능성 높음.

따라서:
- CPU threshold
- MEM threshold

를 더 현실적인 값으로 조정 가능.

---

즉:
- 프로세스명
- 포트
- 로그 위치
- 임계값

이 핵심 변경 포인트.

---

# 리다이렉션 기호 > 와 >> 차이를 설명하고, 로그 누적에 >>가 필요한 이유를 설명할 수 있는가?

## >

```bash
>
```

는:

```text
파일 덮어쓰기(overwrite)
```

.

즉:
- 기존 내용 삭제
- 새 내용 저장.

---

## >>

```bash
>>
```

는:

```text
파일 뒤에 추가(append)
```

.

즉:
- 기존 로그 유지
- 새 로그 누적 저장.

---

현재 monitor.sh는:

```bash
>> "$LOG_FILE"
```

를 사용하였다.

왜냐하면:
- 운영 로그는 시간 흐름 기록이 중요
- 이전 기록 유지 필요

하기 때문이다.

만약 `>`를 사용하면:
- cron 실행 시마다
- 이전 로그 전부 삭제

된다.

---

# monitor.sh에서 프로세스 식별(pgrep/ps 등)과 포트 확인(ss/netstat 등)에 사용한 명령과 선택 이유를 설명할 수 있는가?

현재 프로젝트에서는:

```bash
pgrep -f
```

를 사용하여 프로세스를 식별하였다.

선택 이유:
- PID 추출 간단
- shell script에 적합
- grep 프로세스 중복 문제 감소

장점 때문.

---

포트 확인에는:

```bash
ss -tuln
```

을 사용하였다.

선택 이유:
- 최신 Linux 표준
- netstat보다 빠름
- LISTEN 상태 확인에 적합

하기 때문.

---

현재 monitor.sh 핵심은:

```text
프로세스 상태
+
포트 상태
```

를 함께 점검하여:

```text
실제 서비스 가능 여부
```

를 확인하는 구조라는 점이다.
---

# 프로세스는 살아있는데 포트가 안 열리는 상황의 확인 순서

현재 상황 예시:

```bash
pgrep -f agent-app
```

에서는 PID가 나오는데,

```bash
ss -tulnp | grep 15034
```

에서는 아무것도 안 나오는 상태.

즉:

```text
프로세스는 존재하지만
실제 서비스 포트는 열려 있지 않은 상태
```

이다.

이럴 때는 아래 순서로 원인을 추적한다.

---

# 프로세스 확인

먼저:

```bash
pgrep -af agent-app
```

또는:

```bash
ps -ef | grep agent-app
```

실행.

---

# 왜 먼저 프로세스를 확인하는가

가장 기본은:

```text
프로세스 자체가 정상 실행 중인가
```

를 확인하는 것이다.

---

# 확인하는 것

## PID 존재 여부

예:

```text
5051
```

등 PID 존재 확인.

---

# 실제 실행 명령 확인

예:

```text
python3 agent-app.py
```

처럼 실제 서버 실행 중인지 확인.

---

# 왜 중요한가

단순 PID 존재만으로:
- 정상 실행
- 실제 서비스 가능

이라고 볼 수 없다.

예:
- 무한 루프만 도는 프로세스
- sleep 상태
- zombie process

가능.

---

# 포트 LISTEN 확인

다음:

```bash
ss -tulnp | grep 15034
```

실행.

---

# 확인 목적

현재 app가:

```text
실제로 15034 포트를 열었는가
```

확인.

---

# 정상 상태 예시

```text
tcp LISTEN 0 1 0.0.0.0:15034
```

.

즉:
- 네트워크 연결 대기 상태.

---

# 만약 안 나온다면

현재 상황은:

```text
프로세스는 있지만
포트 bind 실패
```

상태 가능성.

---

# bind 주소 확인

다음으로 확인할 것:

```text
127.0.0.1 인가?
0.0.0.0 인가?
```

.

---

# 왜 중요한가

예를 들어:

```text
127.0.0.1:15034
```

만 열려 있으면:
- 컨테이너 내부 접근만 가능
- 외부 접근 불가.

---

# 정상 외부 서비스라면

보통:

```text
0.0.0.0:15034
```

형태여야 한다.

즉:
- 모든 네트워크 인터페이스 허용.

---

# 확인 방법

```bash
ss -tulnp
```

출력에서 직접 확인.

---

# 포트 충돌 확인

다음 확인:

```text
다른 프로세스가 이미 15034 사용 중인가?
```

.

---

# 확인 방법

```bash
ss -tulnp | grep 15034
```

.

---

# 문제 상황 예시

예:

```text
python PID=3000
```

이미 존재.

그 상태에서:
- 새 agent-app 실행 시
- bind 실패 가능.

---

# 왜 발생하는가

Linux에서는:

```text
같은 포트를 동시에 두 프로세스가 사용 불가
```

하기 때문.

---

# 흔한 오류 메시지

```text
Address already in use
```

.

---

# 로그 확인

다음 단계:

```text
애플리케이션 로그 확인
```

.

---

# 왜 로그를 보는가

실제 bind 실패 원인은:
- 로그에 남는 경우 많음.

예:
- permission denied
- bind failed
- address already in use

등.

---

# 현재 프로젝트 기준 확인 위치

예:

```bash
tail -f /var/log/agent-app/monitor.log
```

또는:
- app stderr 출력
- 실행 터미널 출력

확인.

---

# Docker publish 확인

현재 프로젝트는 Docker 환경이었다.

따라서:
- container 내부 포트
- host 포트 publish

둘 다 중요.

---

# 확인 방법

```bash
docker ps
```

실행.

---

# 정상 예시

```text
0.0.0.0:15034->15034/tcp
```

표시.

즉:
- Host ↔ Container 연결 완료.

---

# 문제 상황

만약 publish 안 되어 있으면:
- container 내부는 정상
- 외부 접근 실패.

---

# 왜 발생하는가

docker 실행 시:

```bash
-p 15034:15034
```

옵션 누락 가능.

---

# 방화벽 확인

마지막으로:

```bash
ufw status
```

확인.

---

# 왜 마지막인가

방화벽은:

```text
포트 자체가 안 열리는 문제
```

가 아니라,

```text
외부 접근 차단 문제
```

이기 때문.

---

# 차이점

## 포트 미오픈

```text
ss에서 안 보임
```

즉:
- app/bind 문제.

---

# 방화벽 문제

```text
ss에서는 LISTEN 보임
```

하지만:
- 외부 접속만 실패.

즉:
- UFW 차단 가능성.

---

# 현재 프로젝트 기준 정상 흐름

```text
agent-app 실행
        ↓
pgrep 로 프로세스 확인
        ↓
ss 로 LISTEN 확인
        ↓
0.0.0.0 bind 확인
        ↓
포트 충돌 여부 확인
        ↓
로그 확인
        ↓
docker publish 확인
        ↓
ufw 허용 확인
```

---

# 왜 이런 순서로 확인하는가

원인을:
- 가장 내부(app)
- 가장 외부(network)

순서로 좁혀가기 때문이다.

즉:

```text
프로세스
→ 포트
→ bind
→ docker
→ firewall
```

순으로 범위를 확장하면서 문제를 찾는다.

---

# 현재 프로젝트 핵심 개념

현재 단계는:

```text
Linux 서버에서
서비스 장애 원인을 단계적으로 추적
```

하는 흐름을 이해하는 과정이다.

즉:
- app 문제
- 포트 문제
- docker 문제
- network 문제

를 구분해서 분석하는 것이 핵심이다.


---
# 로그로 인한 디스크 용량 관리

서버 운영에서는 로그가 계속 증가한다.

예:
- monitor.log
- access.log
- error.log

등.

로그를 제한 없이 계속 저장하면:

```text
디스크 용량 부족
```

문제가 발생한다.

따라서:
- 단기적 관리
- 중장기적 관리

둘 다 중요하다.

---

# 단기적 방법

단기적 방법은:

```text
현재 서버에서
빠르게 로그 증가를 제어하는 방식
```

이다.

즉:
- 즉시 적용 가능
- 간단한 운영 관리

위주.

---

# 로그 rotate

현재 프로젝트에서 사용한 방식.

예:

```text
10MB 초과 시
새 로그 파일 생성
```

.

---

# 방식

예:

```text
monitor.log
```

가 10MB 초과하면:

```text
monitor_20260513_161000.log
```

형태로 이름 변경 후:

```text
새 monitor.log 생성
```

.

---

# 장점

- 구현 간단
- 즉시 적용 가능
- 로그 폭주 방지 가능

.

---

# 오래된 로그 삭제

현재 프로젝트에서:

```bash
tail -n +11 | xargs rm
```

를 사용하여:
- 최신 10개만 유지
- 오래된 로그 삭제

구조 구현.

---

# 장점

```text
디스크 무한 증가 방지
```

가능.

---

# 로그 압축

예:

```bash
gzip monitor.log
```

또는:

```bash
tar -czf logs.tar.gz
```

.

---

# 장점

텍스트 로그는 압축률이 높다.

즉:
- 저장 공간 절약 가능.

---

# cron 기반 자동 정리

예:

```cron
0 3 * * * cleanup.sh
```

처럼:
- 새벽마다 오래된 로그 삭제
- 자동 압축

가능.

---

# 단기적 방법 특징

현재 서버 내부에서:

```text
용량 증가를 빠르게 억제
```

하는 목적.

즉:
- 즉시 대응 중심.

---

# 중장기적 방법

중장기적 방법은:

```text
로그 운영 구조 자체를 개선
```

하는 방식.

즉:
- 대규모 운영
- 장기 보관
- 분석 가능성

고려.

---

# 중앙 로그 서버 구축

예:
- ELK Stack
- Graylog
- Loki

등 사용.

---

# 구조

```text
각 서버 로그
        ↓
중앙 로그 서버 수집
```

.

---

# 장점

- 서버 로컬 디스크 부담 감소
- 통합 검색 가능
- 장애 분석 쉬움

.

---

# 클라우드 로그 저장소 사용

예:
- AWS CloudWatch
- GCP Logging
- Azure Monitor

등.

---

# 장점

- 서버 디스크 사용 최소화
- 장기 보관 가능
- 자동 백업 가능

.

---

# 로그 레벨 관리

모든 로그를 항상 저장하면:
- 로그량 폭증 가능.

따라서:

```text
INFO
WARNING
ERROR
DEBUG
```

등 레벨 분리.

---

# 예시

운영 환경에서는:
- DEBUG 비활성
- ERROR 중심 저장

가능.

---

# 로그 보존 정책 수립

예:

```text
최근 30일 유지
1년 이상은 압축 보관
```

등 정책 구성.

---

# 왜 필요한가

로그는:
- 장애 분석
- 보안 분석
- 감사(audit)

등 중요.

따라서:
- 무조건 삭제도 위험.

즉:
- 보존 기간 정책 필요.

---

# DB 기반 로그 관리

대규모 시스템에서는:
- Elasticsearch
- ClickHouse

등 저장소 사용 가능.

---

# 장점

- 검색 빠름
- 통계 가능
- 시각화 가능

.

---

# 로그 샘플링

트래픽 매우 큰 서비스에서는:

```text
모든 로그 저장 대신 일부만 저장
```

하는 전략 사용 가능.

---

# 왜 필요한가

예:
- 초당 수십만 요청

환경에서는:
- 모든 로그 저장 자체가 부담.

---

# 현재 프로젝트 기준 단기적 방법

현재 프로젝트는:

```text
rotate
+
10개 제한
```

구조를 사용하였다.

즉:
- 간단한 로컬 로그 관리 방식.

---

# 실제 실무에서의 중장기 구조

실무에서는 보통:

```text
애플리케이션 로그
        ↓
Fluentd/Filebeat 수집
        ↓
Elasticsearch 저장
        ↓
Kibana 시각화
```

등 구조 사용.

---

# 단기적 방법과 중장기적 방법 차이

| 구분 | 특징 |
|---|---|
| 단기적 방법 | 현재 서버 디스크 증가 억제 |
| 중장기적 방법 | 로그 시스템 구조 자체 개선 |

---

# 현재 프로젝트 핵심 개념

현재 프로젝트는:

```text
로그는 반드시 관리 대상
```

이라는 개념을 학습하는 과정이다.

즉:
- 로그는 계속 증가
- 디스크는 한정됨

따라서:

```text
rotate
압축
삭제
중앙 수집
```

등 전략이 반드시 필요하다는 것을 이해하는 것이 핵심이다.