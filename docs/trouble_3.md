# cron 자동 실행 시 monitor.log Permission denied 문제 해결

## 문제 상황

`cron`을 사용하여 매분 `monitor.sh`를 자동 실행하도록 설정하였다.

등록한 crontab:

```text id="trcron001"
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
```

하지만 시간이 지나도:

```text id="trcron002"
/var/log/agent-app/monitor.log
```

파일에 새로운 로그가 추가되지 않았다.

즉, cron 자동 실행이 정상적으로 동작하지 않는 것으로 보였다.

---

## 원인 분석 과정

먼저 cron 서비스 실행 여부를 확인하였다.

```bash id="trcron003"
ps -ef | grep cron
```

출력 결과:

```text id="trcron004"
/usr/sbin/cron -P
```

이를 통해 cron 데몬 자체는 정상 실행 중임을 확인하였다.

다음으로 cron 실행 결과를 확인하기 위해 crontab을 아래와 같이 수정하였다.

```text id="trcron005"
* * * * * /home/agent-admin/agent-app/bin/monitor.sh >> /tmp/cron_test.log 2>&1
```

이후 로그 파일을 확인하였다.

```bash id="trcron006"
cat /tmp/cron_test.log
```

출력 결과:

```text id="trcron007"
/home/agent-admin/agent-app/bin/monitor.sh: line 87:
/var/log/agent-app/monitor.log: Permission denied
```

이를 통해:

* cron은 정상적으로 monitor.sh를 실행하고 있었으나
* 실행 계정(agent-admin)이 monitor.log 파일에 기록할 권한이 없어
* 로그 저장 단계에서 실패하고 있었음을 확인하였다.

---

## 원인

`monitor.log` 파일의 소유자 및 권한 설정이 잘못되어 있었다.

즉:

```text id="trcron008"
agent-admin 계정이 monitor.log에 write 불가능
```

상태였다.

---

## 해결 방법

root 계정으로 아래 명령어를 실행하였다.

```bash id="trcron009"
touch /var/log/agent-app/monitor.log

chown agent-admin:agent-core /var/log/agent-app/monitor.log

chmod 660 /var/log/agent-app/monitor.log
```

---

## 권한 설정 의미

```text id="trcron010"
660
```

의 의미:

* owner: read/write
* group: read/write
* others: 접근 불가

즉:

* agent-admin
* agent-core 그룹 사용자

만 로그 파일 접근 가능하도록 설정하였다.

---

## 결과 확인

이후 다시 로그를 확인하였다.

```bash id="trcron011"
tail -n 20 /var/log/agent-app/monitor.log
```

출력 결과:

```text id="trcron012"
[2026-05-13 16:09:01] ...
[2026-05-13 16:10:01] ...
```

1분 단위로 새로운 로그가 자동 추가되는 것을 확인하였다.

이를 통해:

* cron 자동 실행 정상 동작
* monitor.sh 정상 실행
* monitor.log append 성공

상태임을 검증하였다.

---

## 학습한 내용

* cron은 별도의 독립 환경에서 실행된다.
* cron 동작 여부는 `/tmp/cron_test.log` 같은 디버깅 로그를 통해 검증할 수 있다.
* 서비스 자동화 시 실행 계정의 파일 권한 문제가 자주 발생한다.
* 리눅스 서버 운영에서는 로그 디렉토리 및 파일 권한 관리가 매우 중요하다.
