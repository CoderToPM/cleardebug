#!/bin/bash

#1、查tomcat进程中存在Xdebug或agentlib形式的debug启动的进程列表
#2、找到相应的startenv.sh文件，删除相应的debug代码
#3、socat进程删除

function getNow()
{
  now=`date "+%Y-%m-%d %H:%M:%S"`;
  echo $now;
}

function log(){
    echo $(getNow) $1| sudo tee -a /home/yourusername/cleardebug/logs/main.log;
}

log "---begin"
numberOfProblems=0;
#一、清理debug
log "一、清理debug";
# 获取startenv.sh文件的所有目录
SERVERLIST=`ps -ef|grep 'tomcat'|grep -E '\-Xdebug|agentlib:jdwp' --color|awk -F'Dcatalina.base=' '{print $2}'|awk -F' ' '{print $1}'`
for file in ${SERVERLIST[@]};
do
	log '开始清理'$file'里面的debug';
	let numberOfProblems+=1;
	sudo sed -ri 's/(^[^#].*?)(-Xdebug\s+-Xrunjdwp)[^ "]*/\1/g' ${file}/startenv.sh && sudo sed -ri 's/(^[^#].*?)(-agentlib)[^ "]*/\1/g' ${file}/startenv.sh && sudo /home/yourusername/tomcat/bin/restart_tomcat.sh $file
done

log "二、清理远程socat连接";
#二、清理远程socat连接
#pkill -９ socat
#ps -ef | grep socat | grep -v grep | cut -c 9-15 |sudo xargs kill -s 9
sudo killall -9 socat && let numberOfProblems+=1;

log "三、清理root启动的tomcat";
#三、清理root启动的tomcat
ROOTSTARTSERVERLIST=`ps -ef | grep tomcat|awk -F ' ' '{if ($1 == "root") print $0}' |awk -F'Dcatalina.base=' '{print $2}'|awk -F' ' '{print $1}'`
for catalinaBase in ${ROOTSTARTSERVERLIST[@]};
do
	log '开始清理'$catalinaBase'的root启动问题';
	let numberOfProblems+=1;
	sudo sed -ri 's/TOMCAT_USER="root"/TOMCAT_USER="tomcat"/g' ${catalinaBase}/startenv.sh;
	sudo /home/yourusername/tomcat/bin/restart_tomcat.sh $catalinaBase;
done
log "numberOfProblems:"$numberOfProblems;
log "---complete";
