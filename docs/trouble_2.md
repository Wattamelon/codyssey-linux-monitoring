# Docker 컨테이너에서 UFW 활성화 실패 문제 해결

## 문제 상황

Docker 컨테이너 내부에서 UFW 방화벽 설정을 진행하였다.

실행 명령어:

```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
ufw enable
ufw status
```

하지만 아래와 같은 오류가 발생하였다.

```text
iptables v1.8.10 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)

ERROR: problem running ufw-init
Problem running '/etc/ufw/before.rules'
Problem running '/etc/ufw/after.rules'
Problem running '/etc/ufw/user.rules'
```

또한 여러 `sysctl` 관련 오류와 함께 UFW 활성화가 실패하였다.

---

## 원인 분석

처음에는 root 권한 문제로 보였지만, 실제 원인은 Docker 컨테이너의 기본 권한 제한 때문이었다.

Docker 컨테이너는 기본적으로:

* iptables 조작
* 커널 네트워크 설정
* 방화벽 정책 변경

과 같은 네트워크 관리자 기능이 제한되어 있다.

즉 컨테이너 내부에서 root 계정으로 실행하더라도, Docker가 해당 capability를 허용하지 않으면 UFW 및 iptables를 정상적으로 사용할 수 없다.

이번 문제의 핵심 원인은:

```text
NET_ADMIN capability 미부여
```

상태에서 컨테이너를 실행했기 때문이었다.

---

## 해결 방법

기존 컨테이너를 종료 및 삭제한 후, `NET_ADMIN` capability를 추가하여 새 컨테이너를 생성하였다.

### 기존 컨테이너 종료

```bash
docker stop codyssey-week1
```

### 기존 컨테이너 삭제

```bash
docker rm codyssey-week1
```

### 권한 추가 후 새 컨테이너 생성

```bash
docker run -it \
  --name codyssey-week1 \
  --cap-add=NET_ADMIN \
  -p 20022:20022 \
  -p 15034:15034 \
  -v $(pwd):/workspace \
  ubuntu:24.04 bash
```

---

## 핵심 옵션 설명

```text
--cap-add=NET_ADMIN
```

의 의미:

* 컨테이너에 네트워크 관리자 capability 추가
* iptables 및 UFW 사용 가능
* 네트워크 인터페이스 및 방화벽 설정 허용

즉 컨테이너 내부에서 방화벽 정책을 수정할 수 있는 권한을 부여한 것이다.

---

## 학습한 내용

* Docker 컨테이너의 root 계정은 호스트 운영체제의 완전한 root 권한과 동일하지 않다.
* Docker는 기본적으로 네트워크 관련 capability를 제한한다.
* UFW는 내부적으로 iptables를 사용하므로 `NET_ADMIN` capability가 필요하다.
* Docker 환경에서 방화벽 및 네트워크 설정을 사용하려면 컨테이너 생성 시 capability 옵션을 명시적으로 추가해야 한다.
