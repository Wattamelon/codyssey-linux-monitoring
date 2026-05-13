

# 1. git clone & docker container setting
```bash
seongon10104692@c4r1s3 codyssey-linux-monitoring % git clone https://github.com/Wattamelon/codyssey-linux-monitoring.git
Cloning into 'codyssey-linux-monitoring'...
remote: Enumerating objects: 13, done.
remote: Counting objects: 100% (13/13), done.
remote: Compressing objects: 100% (7/7), done.
remote: Total 13 (delta 0), reused 13 (delta 0), pack-reused 0 (from 0)
Receiving objects: 100% (13/13), 7.51 MiB | 34.19 MiB/s, done.
seongon10104692@c4r1s3 codyssey-linux-monitoring % cd codyssey-linux-monitoring 
seongon10104692@c4r1s3 codyssey-linux-monitoring % docker run -it \
  --name codyssey-week1 \
  -p 20022:20022 \
  -p 15034:15034 \
  -v $(pwd):/workspace \
  ubuntu:24.04 bash
Unable to find image 'ubuntu:24.04' locally
24.04: Pulling from library/ubuntu
b40150c1c271: Pull complete 
92842f25412d: Download complete 
Digest: sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b
Status: Downloaded newer image for ubuntu:24.04
root@d3b412c69a10:/# 


apt update

apt install -y \
openssh-server \
sudo \
nano \
vim \
iproute2 \
net-tools \
cron \
ufw \
acl \
procps
```

# 2. ssh 서버 구축
```bash
nano /etc/ssh/sshd_config

Port 20022
PermitRootLogin no

mkdir -p /run/sshd

/usr/sbin/sshd

root@d3b412c69a10:/# ss -tulnp | grep 20022
tcp   LISTEN 0      128          0.0.0.0:20022      0.0.0.0:*    users:(("sshd",pid=4730,fd=3))
tcp   LISTEN 0      128             [::]:20022         [::]:*    users:(("sshd",pid=4730,fd=4))
```
# 3. 계정 생성
```bash
adduser agent-admin
adduser agent-dev
adduser agent-test

root@d3b412c69a10:/# id agent-admin
id agent-dev
id agent-test
uid=1001(agent-admin) gid=1001(agent-admin) groups=1001(agent-admin),100(users)
uid=1002(agent-dev) gid=1002(agent-dev) groups=1002(agent-dev),100(users)
uid=1003(agent-test) gid=1003(agent-test) groups=1003(agent-test),100(users)
```
# 4. SSH 실제 접속 테스트
```bash
새로운 터미널 오픈
seongon10104692@c4r1s3 codyssey-linux-monitoring % ssh agent-admin@localhost -p 20022
The authenticity of host '[localhost]:20022 ([::1]:20022)' can't be established.
ED25519 key fingerprint is SHA256:jH1kh3g793Dhh2RHV3Y9qAIHYoPcVLILbwCWB6wBzAw.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? ㅛyes
Warning: Permanently added '[localhost]:20022' (ED25519) to the list of known hosts.
agent-admin@localhost's password: 
Permission denied, please try again.
agent-admin@localhost's password: 
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.19.13-orbstack-gbd1dc07b8cf4 x86_64)

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

agent-admin@d3b412c69a10:~$ 
```
# 5. 그룹 생성 및 연결 
```bash
groupadd agent-common
groupadd agent-core

usermod -aG agent-common agent-admin
usermod -aG agent-common agent-dev
usermod -aG agent-common agent-test

usermod -aG agent-core agent-admin
usermod -aG agent-core agent-dev
```
# 6. 디렉토리 구조 생성
```bash
mkdir -p /home/agent-admin/agent-app/upload_files
mkdir -p /home/agent-admin/agent-app/api_keys
mkdir -p /home/agent-admin/agent-app/bin
mkdir -p /var/log/agent-app

root@d3b412c69a10:/# ls
bin  bin.usr-is-merged  boot  dev  etc  home  lib  lib.usr-is-merged  lib64  media  mnt  opt  proc  root  run  sbin  sbin.usr-is-merged  srv  sys  tmp  usr  var  workspace
root@d3b412c69a10:/# cd home/agent-admin/agent-app/
root@d3b412c69a10:/home/agent-admin/agent-app# ls
api_keys  bin  upload_files
root@d3b412c69a10:/home/agent-admin/agent-app# 
```
# 7. 디렉토리 권한 설정
```bash
chown -R agent-admin:agent-common /home/agent-admin/agent-app/upload_files
chmod 770 /home/agent-admin/agent-app/upload_files

chown -R agent-admin:agent-core /home/agent-admin/agent-app/api_keys
chmod 770 /home/agent-admin/agent-app/api_keys

chown -R agent-admin:agent-core /var/log/agent-app
chmod 770 /var/log/agent-app

ls -l /home/agent-admin/agent-app
root@d3b412c69a10:/# ls -l /home/agent-admin/agent-app
total 0
drwxrwx--- 1 agent-admin agent-core   0 May 13 14:55 api_keys
drwxr-xr-x 1 root        root         0 May 13 14:55 bin
drwxrwx--- 1 agent-admin agent-common 0 May 13 14:55 upload_files
root@d3b412c69a10:/# ls -ld /var/log/agent-app
drwxrwx--- 1 agent-admin agent-core 0 May 13 14:55 /var/log/agent-app
root@d3b412c69a10:/# 
```
# 8. ACL 확인 
```bash
getfacl /home/agent-admin/agent-app/upload_files
getfacl /home/agent-admin/agent-app/api_keys

root@d3b412c69a10:/# getfacl /home/agent-admin/agent-app/upload_files
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
```
# 9. 환경 변수 설정
```bash
export AGENT_HOME=/home/agent-admin/agent-app

export AGENT_PORT=15034

export AGENT_UPLOAD_DIR=$AGENT_HOME/upload_files

export AGENT_KEY_PATH=$AGENT_HOME/api_keys/t_secret.key

export AGENT_LOG_DIR=/var/log/agent-app

root@d3b412c69a10:/# echo $AGENT_HOME
echo $AGENT_PORT
echo $AGENT_UPLOAD_DIR
echo $AGENT_KEY_PATH
echo $AGENT_LOG_DIR
/home/agent-admin/agent-app
15034
/home/agent-admin/agent-app/upload_files
/home/agent-admin/agent-app/api_keys/t_secret.key
/var/log/agent-app
root@d3b412c69a10:/# 

키 파일 생성
echo "agent_api_key_test" > /home/agent-admin/agent-app/api_keys/t_secret.key

키 파일 권한
chown agent-admin:agent-core /home/agent-admin/agent-app/api_keys/t_secret.key

chmod 660 /home/agent-admin/agent-app/api_keys/t_secret.key

root@d3b412c69a10:/# ls -l /home/agent-admin/agent-app/api_keys/t_secret.key
-rw-rw---- 1 agent-admin agent-core 19 May 13 15:02 /home/agent-admin/agent-app/api_keys/t_secret.key
```
# 10. GitHub 레포에 있는 app 복사.
```bash
root@d3b412c69a10:/# cp /workspace/app/agent-app /home/agent-admin/agent-app/
root@d3b412c69a10:/# chmod +x /home/agent-admin/agent-app/agent-app
```
# 11. root -> agent-admin 계정으로 전환
```bash
su - agent-admin

root@d3b412c69a10:/# su - agent-admin
agent-admin@d3b412c69a10:~$ 

```
# 12. agent-app 실행
```bash
/home/agent-admin/agent-app/agent-app

agent-admin@d3b412c69a10:~$ /home/agent-admin/agent-app/agent-app
>>> Starting Agent Boot Sequence...
[1/5] Checking User Account               [OK]
 ... Running as service user 'agent-admin' (uid=1001)
[2/5] Verifying Environment Variables     [OK]
 ... All required Envs correct
[3/5] Checking Required Files             [OK]
 ... Verified 'secret.key' with correct key string.
[4/5] Checking Port Availability          [OK]
 ... Port 15034 is available.
[5/5] Verifying Log Permission            [OK]
 ... Log directory is writable: /var/log/agent-app
------------------------------------------------------------
All Boot Checks Passed!
Agent READY
2026-05-13 15:08:58,741 [INFO] [SafetyGuard] Process priority lowered (nice=10).
2026-05-13 15:08:58,741 [INFO] Agent listening at port 15034
2026-05-13 15:08:58,741 [INFO] === Agent Started. Beginning resource cycle. ===
2026-05-13 15:08:58,741 [INFO] --- Step Info: Mode=UP, CPU Lv=1, Mem=0MB ---
2026-05-13 15:08:58,780 [INFO] [Memory] Increasing... (+25 MB) Total: 25 MB
2026-05-13 15:08:58,807 [INFO] [CPU] Level 1 workload completed. Duration: 0.03s
2026-05-13 15:08:59,807 [INFO] --- Step Info: Mode=UP, CPU Lv=2, Mem=25MB ---
2026-05-13 15:08:59,846 [INFO] [Memory] Increasing... (+25 MB) Total: 50 MB
2026-05-13 15:08:59,899 [INFO] [CPU] Level 2 workload completed. Duration: 0.05s
2026-05-13 15:09:00,901 [INFO] --- Step Info: Mode=UP, CPU Lv=3, Mem=50MB ---
2026-05-13 15:09:00,939 [INFO] [Memory] Increasing... (+25 MB) Total: 75 MB
2026-05-13 15:09:01,018 [INFO] [CPU] Level 3 workload completed. Duration: 0.08s
2026-05-13 15:09:02,019 [INFO] --- Step Info: Mode=UP, CPU Lv=4, Mem=75MB ---
2026-05-13 15:09:02,060 [INFO] [Memory] Increasing... (+25 MB) Total: 100 MB
2026-05-13 15:09:02,165 [INFO] [CPU] Level 4 workload completed. Duration: 0.10s
2026-05-13 15:09:03,166 [INFO] --- Step Info: Mode=UP, CPU Lv=5, Mem=100MB ---
2026-05-13 15:09:03,206 [INFO] [Memory] Increasing... (+25 MB) Total: 125 MB
2026-05-13 15:09:03,336 [INFO] [CPU] Level 5 workload completed. Duration: 0.13s
2026-05-13 15:09:04,338 [INFO] --- Step Info: Mode=UP, CPU Lv=6, Mem=125MB ---
2026-05-13 15:09:04,378 [INFO] [Memory] Increasing... (+25 MB) Total: 150 MB
2026-05-13 15:09:04,534 [INFO] [CPU] Level 6 workload completed. Duration: 0.16s
2026-05-13 15:09:05,535 [INFO] --- Step Info: Mode=UP, CPU Lv=7, Mem=150MB ---
2026-05-13 15:09:05,575 [INFO] [Memory] Increasing... (+25 MB) Total: 175 MB
2026-05-13 15:09:05,757 [INFO] [CPU] Level 7 workload completed. Duration: 0.18s
2026-05-13 15:09:06,758 [INFO] --- Step Info: Mode=UP, CPU Lv=8, Mem=175MB ---
2026-05-13 15:09:06,798 [INFO] [Memory] Increasing... (+25 MB) Total: 200 MB
2026-05-13 15:09:07,004 [INFO] [CPU] Level 8 workload completed. Duration: 0.21s
2026-05-13 15:09:08,006 [INFO] --- Step Info: Mode=UP, CPU Lv=9, Mem=200MB ---
2026-05-13 15:09:08,045 [INFO] [Memory] Increasing... (+25 MB) Total: 225 MB
2026-05-13 15:09:08,279 [INFO] [CPU] Level 9 workload completed. Duration: 0.23s
```
# 13. 확인
```bash
새 터미널 오픈

docker exec -it codyssey-week1 bash

root@d3b412c69a10:/# ss -tulnp | grep 15034
tcp   LISTEN 0      1            0.0.0.0:15034      0.0.0.0:*                                  
root@d3b412c69a10:/# 
```
# 14. monitor.sh 배치 및 실행
```bash
cp /workspace/scripts/monitor.sh /home/agent-admin/agent-app/bin/monitor.sh
chown agent-dev:agent-core /home/agent-admin/agent-app/bin/monitor.sh
chmod 750 /home/agent-admin/agent-app/bin/monitor.sh

root@d3b412c69a10:/# ls -l /home/agent-admin/agent-app/bin/monitor.sh
-rwxr-x--- 1 agent-dev agent-core 2625 May 13 15:16 /home/agent-admin/agent-app/bin/monitor.sh
root@d3b412c69a10:/# bash -n /home/agent-admin/agent-app/bin/monitor.sh

/home/agent-admin/agent-app/bin/monitor.sh

root@d3b412c69a10:/# /home/agent-admin/agent-app/bin/monitor.sh
====== SYSTEM MONITOR RESULT ======
[HEALTH CHECK]
Checking process 'agent-app'... [OK] (PID: 4949
4950
5220)
Checking port 15034... [OK]
[FIREWALL CHECK]
ERROR: problem running iptables: iptables v1.8.10 (nf_tables): Could not fetch rule set generation id: Permission denied (you must be root)


UFW Status... [WARNING] Firewall inactive
[RESOURCE MONITORING]
CPU Usage : 100%
MEM Usage : 5.9%
DISK Used : 1%
[WARNING] CPU threshold exceeded (100% > 20%)
[INFO] Log appended: /var/log/agent-app/m

root@d3b412c69a10:/# tail -n 5 /var/log/agent-app/monitor.log
[2026-05-13 15:17:08] PID:4949
4950
5220 CPU:100% MEM:5.9% DISK_USED:1%
root@d3b412c69a10:/# 

ufw allow 20022/tcp
ufw allow 15034/tcp
ufw enable
ufw status 
```
--------------------------------------------------실행 및 오류 (트러블슈팅2) , 컨테이너 재생성--------------------------------------------------

