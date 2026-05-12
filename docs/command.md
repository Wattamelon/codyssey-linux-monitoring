1. 컨테이너 생성
docker run -it \
  --name codyssey-week1 \
  -p 20022:20022 \
  -p 15034:15034 \
  -v $(pwd):/workspace \
  ubuntu:22.04 bash
Unable to find image 'ubuntu:22.04' locally
22.04: Pulling from library/ubuntu
6edbc812af48: Pull complete 
Digest: sha256:962f6cadeae0ea6284001009daa4cc9a8c37e75d1f5191cf0eb83fe565b63dd7
Status: Downloaded newer image for ubuntu:22.04
root@09a31377137e:/# 

2. 우분투 환경세팅
apt update
apt install -y openssh-server sudo nano vim iproute2 net-tools cron ufw acl procps

3. workspace 확인
root@09a31377137e:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var  workspace
root@09a31377137e:/# cd workspace/
root@09a31377137e:/workspace# ls
README.md  app  docker  docs  evidence  scripts


4. ssh 설정

SSH 서버 설정파일 열기
nano /etc/ssh/sshd_config

#PermitRootLogin prohibit-password -> PermitRootLogin no
Port 20022 추가

SSH 서버가 실행될 때 필요한 런타임 폴더 생성
root@09a31377137e:/# mkdir -p /run/sshd

SSH 서버 프로그램 실행
/usr/sbin/sshd

현재 열려있는 포트 확인
root@09a31377137e:/# ss -tulnp | grep 20022
tcp   LISTEN 0      128          0.0.0.0:20022      0.0.0.0:*    users:(("sshd",pid=38,fd=3))
tcp   LISTEN 0      128             [::]:20022         [::]:*    users:(("sshd",pid=38,fd=4))
root@09a31377137e:/# 

일반계정 생성
root@09a31377137e:/# adduser agent-admin
Adding user `agent-admin' ...
Adding new group `agent-admin' (1000) ...
Adding new user `agent-admin' (1000) with group `agent-admin' ...
Creating home directory `/home/agent-admin' ...
Copying files from `/etc/skel' ...
New password: 
Retype new password: 
Sorry, passwords do not match.
passwd: Authentication token manipulation error
passwd: password unchanged
Try again? [y/N] y    
New password: 
Retype new password: 
passwd: password updated successfully
Changing the user information for agent-admin
Enter the new value, or press ENTER for the default
        Full Name []: 
        Room Number []: 
        Work Phone []: 
        Home Phone []: 
        Other []: 
Is the information correct? [Y/n] Y
root@09a31377137e:/# 

adduser agent-dev
adduser agent-test 도 생성

root@09a31377137e:/# id agent-admin
id agent-dev
id agent-test
uid=1000(agent-admin) gid=1000(agent-admin) groups=1000(agent-admin)
uid=1001(agent-dev) gid=1001(agent-dev) groups=1001(agent-dev)
uid=1002(agent-test) gid=1002(agent-test) groups=1002(agent-test)

5. SSH 실제 접속 테스트

새로운 터미널 open
(base) melon@munseongon-ui-MacBookAir codyssey-linux-monitoring % ssh agent-admin@localhost -p 20022
The authenticity of host '[localhost]:20022 ([::1]:20022)' can't be established.
ED25519 key fingerprint is SHA256:FTI02mYgEwOpSjCzmYabWl+yEDIn60095jHcWSbK8/k.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])?  yes
Warning: Permanently added '[localhost]:20022' (ED25519) to the list of known hosts.
agent-admin@localhost's password: 
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 7.0.5-orbstack-00330-ge3df4e19b0a0-dirty aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

agent-admin@09a31377137e:~$ 

6. 그룹 생성

groupadd agent-common
groupadd agent-core

usermod -aG agent-common agent-admin
usermod -aG agent-common agent-dev
usermod -aG agent-common agent-test

usermod -aG agent-core agent-admin
usermod -aG agent-core agent-dev

7. 우분투 루트 계정에서 디렉토리 생성

mkdir -p /home/agent-admin/agent-app/upload_files
mkdir -p /home/agent-admin/agent-app/api_keys
mkdir -p /home/agent-admin/agent-app/bin
mkdir -p /var/log/agent-app

생성된 디렉토리 확인
root@09a31377137e:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var  workspace
root@09a31377137e:/# cd home
root@09a31377137e:/home# ls
agent-admin  agent-dev  agent-test
root@09a31377137e:/home# cd agent-admin/
root@09a31377137e:/home/agent-admin# ls
agent-app
root@09a31377137e:/home/agent-admin# cd agent-app/
root@09a31377137e:/home/agent-admin/agent-app# ls
api_keys  bin  upload_files
root@09a31377137e:/home/agent-admin/agent-app# 

root@09a31377137e:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var  workspace
root@09a31377137e:/# cd var
root@09a31377137e:/var# ls
backups  cache  lib  local  lock  log  mail  opt  run  spool  tmp
root@09a31377137e:/var# cd log/agent-app/
root@09a31377137e:/var/log/agent-app# ls
root@09a31377137e:/var/log/agent-app# 

8. upload_files 권한 설정

root@09a31377137e:/# chown -R agent-admin:agent-common /home/agent-admin/agent-app/upload_files
chmod 770 /home/agent-admin/agent-app/upload_files
root@09a31377137e:/# 

9. api_keys 권한 설정

root@09a31377137e:/# chown -R agent-admin:agent-core /home/agent-admin/agent-app/api_keys
chmod 770 /home/agent-admin/agent-app/api_keys
root@09a31377137e:/# 

10. 로그 디렉토리 권한 설정

root@09a31377137e:/# chown -R agent-admin:agent-core /var/log/agent-app
chmod 770 /var/log/agent-app
root@09a31377137e:/# 

11. 구조 확인

root@09a31377137e:/# ls -l /home/agent-admin/agent-app
total 0
drwxrwx--- 1 agent-admin agent-core   0 May 12 06:53 api_keys
drwxr-xr-x 1 root        root         0 May 12 06:53 bin
drwxrwx--- 1 agent-admin agent-common 0 May 12 06:53 upload_files
root@09a31377137e:/# ls -ld /var/log/agent-app
drwxrwx--- 1 agent-admin agent-core 0 May 12 06:53 /var/log/agent-app
root@09a31377137e:/# 

12. ACL확인

root@09a31377137e:/# getfacl /home/agent-admin/agent-app/upload_files
getfacl /home/agent-admin/agent-app/api_keys
getfacl: Removing leading '/' from absolute path names
# file: home/agent-admin/agent-app/upload_files
# owner: agent-admin
# group: agent-common
user::rwx
group::rwx
other::---

getfacl: Removing leading '/' from absolute path names
# file: home/agent-admin/agent-app/api_keys
# owner: agent-admin
# group: agent-core
user::rwx
group::rwx
other::---

root@09a31377137e:/# 

13. 개념확인

upload_files
→ 협업 공간

api_keys
→ 민감 정보 저장소

log
→ 운영 정보 저장소

이므로 각 폴더의 권한을 전부 다르게 줌.

14. 키 파일 생성

root@09a31377137e:/# echo "agent_api_key_test" > /home/agent-admin/agent-app/api_keys/t_secret.key

chown agent-admin:agent-core /home/agent-admin/agent-app/api_keys/t_secret.key
chmod 660 /home/agent-admin/agent-app/api_keys/t_secret.key
root@09a31377137e:/# ls -l /home/agent-admin/agent-app/api_keys/t_secret.key
cat /home/agent-admin/agent-app/api_keys/t_secret.key
-rw-rw---- 1 agent-admin agent-core 19 May 12 07:10 /home/agent-admin/agent-app/api_keys/t_secret.key
agent_api_key_test
root@09a31377137e:/# 

15. monitor.sh 작성

root@09a31377137e:/# nano /workspace/scripts/monitor.sh

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
PID=$(pgrep -f "$APP_NAME")

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

root@09a31377137e:/# 

16. 컨테이너 과제 경로로 복사

root@09a31377137e:/# cp /workspace/scripts/monitor.sh /home/agent-admin/agent-app/bin/monitor.sh

chown agent-dev:agent-core /home/agent-admin/agent-app/bin/monitor.sh

chmod 750 /home/agent-admin/agent-app/bin/monitor.sh
root@09a31377137e:/# 

확인

root@09a31377137e:/# ls -l /home/agent-admin/agent-app/bin/monitor.sh
-rwxr-x--- 1 agent-dev agent-core 2625 May 12 07:17 /home/agent-admin/agent-app/bin/monitor.sh
root@09a31377137e:/# 