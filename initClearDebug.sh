#!/usr/bin/env bash
echo "---begin";
echo "---开始给脚本添加可执行权限";
sudo chmod 775 /home/yourusername/cleardebug/scripts/clearDebug.sh;
echo "开始检测日志文件是否存在";
if [ ! -f "/home/yourusername/cleardebug/logs/main.log" ];then
    sudo mkdir -p /home/yourusername/cleardebug/logs/ && sudo touch /home/yourusername/cleardebug/logs/main.log;
    sudo chmod 755 /home/yourusername/cleardebug/logs/main.log;
    echo "日志文件新建成功" | sudo tee -a /home/yourusername/cleardebug/logs/main.log;
else
    echo "日志文件已经存在，不再重新创建" | sudo tee -a /home/yourusername/cleardebug/logs/main.log;
fi
echo "先执行一遍安全清理";
sudo /home/yourusername/cleardebug/scripts/clearDebug.sh;

#清理之前的clearDebug.sh脚本
echo "把之前的定时任务脚本清理掉";
sudo sed -i '/tools\/bin\/clearXdebug.sh/d' /var/spool/cron/root;
sudo sed -i '/tools\/bin\/clearDebug.sh/d' /var/spool/cron/root;
sudo sed -i '/cleardebug\/clearDebug.sh/d' /var/spool/cron/root;
sudo sed -i '/cleardebug\/scripts\/clearDebug.sh/d' /var/spool/cron/root;

#把空行删掉
sudo  sed -i '/^$/d' /var/spool/cron/root;

echo "开始把脚本添加到定时任务去执行";
echo '00 03 * * * export LANG=zh_CN.UTF-8; result=$(/home/yourusername/cleardebug/scripts/clearDebug.sh) ; [[ $result == *numberOfProblems:0* ]] && echo "has no debug or root" || echo -e "debug code has been auto cleared. ——Powered by yongchaohe,as follows.\n$result" | mail -s "debug has been cleared" yongchaohe@gmail.com,xxx@xx.com' | sudo tee -a /var/spool/cron/root && sudo service crond reload;
echo "目前定时任务脚本触发成功，就会发送邮件到yongchao.he@qunar.com,xxx@xx.com";
echo "列出当前机器上有效的定时任务";
sudo crontab -l |grep clearDebug.sh --color;
echo "---complete";
