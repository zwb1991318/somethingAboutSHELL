#!/bin/sh
mkdir logs
echo $$>autoRunTomcat.pid

dos2unix ../webapps/WebReport/WEB-INF/deploy/deploy-frame.properties
exec 6< ../webapps/WebReport/WEB-INF/deploy/deploy-frame.properties
while read -u 6 myline  
do  
    if [[ $myline =~ "autoRunTime" ]]; then
     	 zwbtemp=${myline##*=}
     fi 
done

pid=`echo $$`
pname=`echo $0`
mypidfile=~/pid.test
flagmun=0
# echo -e "\n pid=$pid  pname=$pname \n"

function autoRunTomcat(){
     while [[ true ]]; do
     	sleep ${zwbtemp}
     	result=`lsof ../webapps/WebReport/lock.txt`
     	if [[ $result =~ "java" ]]
     	then
     		flagmun=0
	    else
            if [[ $flagmun == "3" ]]; then
                exit 1
            else
                flagmun=$[$flagmun+1]
                dateShow=`date`
                dateWrite=`date +%Y%m%d%H%M%S`
                mkdir logs/$dateWrite
                cp -r ../logs logs/$dateWrite
                sh tomcat.sh
                echo "检测到tomcat未运行，重启tomcat"$dateShow >> autoRunTomcat.log                  
            fi
	    	
	     	sleep 10
     	fi
     done
}

sleep 20
if test -f "$mypidfile"
then
     expid=`cat $mypidfile`
     # echo "expid=$expid"
     pfalg=`ps -ef|grep "$expid"|grep "$pname"|wc -l`
     if [ "1" = "$pfalg" ]
     then
           #It's a joke
            fuck="1"
     else
          echo $pid > $mypidfile
          autoRunTomcat          
     fi
else
     echo $pid > $mypidfile
  	autoRunTomcat 
     
fi
