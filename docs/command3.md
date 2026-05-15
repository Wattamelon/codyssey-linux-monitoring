진행한 부분들은 표기 후 설명 생략

# 1. 컨테이너 재생성
```bash
docker run -it \
  --name codyssey-week1 \
  --privileged \
  -p 20022:20022 \
  -p 15034:15034 \
  -v $(pwd):/workspace \
  ubuntu:24.04 bash
```

# 2. 패키지 설치

# 3. SSH 설정

# 4. 계정 생성

# 5. 그룹 생성 및 연결

# 6. 디렉토리/권한 설정

# 7. 환경변수 , 키 파일 , 앱

# 8. monitor.sh 배치 및 실행

# 9. UFW 방화벽 설정
```bash
ufw allow 20022/tcp
ufw allow 15034/tcp
ufw enable
ufw status

root@4d39a92c9967:/# ufw allow 20022/tcp
ufw allow 15034/tcp
ufw enable
ufw status
Rules updated
Rules updated (v6)
Rules updated
Rules updated (v6)
Firewall is active and enabled on system startup
Status: active

To                         Action      From
--                         ------      ----
20022/tcp                  ALLOW       Anywhere                  
15034/tcp                  ALLOW       Anywhere                  
20022/tcp (v6)             ALLOW       Anywhere (v6)             
15034/tcp (v6)             ALLOW       Anywhere (v6)             
```
# 10. cron
```bash
service cron start

root@4d39a92c9967:/# service cron start
 * Starting periodic command scheduler cron        

 crontab -u agent-admin -e

맨 아래에 추가
 * * * * * /home/agent-admin/agent-app/bin/monitor.sh

 crontab -u agent-admin -l

 root@4d39a92c9967:/# crontab -u agent-admin -l
# Edit this file to introduce tasks to be run by cron.
# 
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
# 
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
# 
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# 
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
* * * * * /home/agent-admin/agent-app/bin/monitor.sh
root@4d39a92c9967:/# 

# 11. cron 작동 확인
```bash
tail -n 20 /var/log/agent-app/monitor.log

--- 트러블 슈팅 발생 (trouble_3.md)

root@4d39a92c9967:/# tail -n 20 /var/log/agent-app/monitor.log
[2026-05-13 15:52:07] PID:5051
5052
5068 CPU:100% MEM:4.6% DISK_USED:1%
[2026-05-13 15:54:46] PID:5051
5052
5260 CPU:11.3% MEM:4.4% DISK_USED:1%
[2026-05-13 16:09:01] PID:5051
5052
5611
5612 CPU:1.6% MEM:4.0% DISK_USED:1%
[2026-05-13 16:10:01] PID:5051
5052
5638
5639 CPU:17.5% MEM:5.4% DISK_USED:1%
root@4d39a92c9967:/# 
```