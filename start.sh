#!/bin/bash
if [ -f "conf.sh" ]
then
	echo "Hello World!"
else
	echo "MAXHEAP=1024
MINHEAP=1024
MAXHEAP=1024
CPU_COUNT=1
SERVICE='minecraft_server.jar'
OPTIONS='nogui server'
#put snapshot or release
UPDATE='snapshot'
ENABLEUPDATE='true'
#RESTART ON CRASH
RESTARTCRASH='true'
timelimit=10
#TimeLimit in seconds before restart. Press any key inbetween timelimit to stop server.
updatestart='true'
#MINHEAP option s MAXHEAP option x and options o
DFTBA='TRUE'" > conf.sh
fi
echo 'Reading Configuration File'
./conf.sh
./currentversion.sh
echo 'Done Reading Configuration File'
echo 'Configuring Functions'
while getopts rxscu option do case "${option}" in r) RESTARTCRASHtemp=${OPTARG};; x) MAXHEAPtemp=${OPTARG};; s) MINHEAPtemp=${OPTARG};; o) OPTIONStemp=${OPTARG};; esac done
if [[ -z "$RESTARTCRASHtemp" ]]
then
else
RESTARTCRASH=$RESTARTCRASHtemp
fi
if [[ -z "$MAXHEAPtemp" ]]
then
else
MAXHEAP=$MAXHEAPtemp
fi
if [[ -z "$MINHEAPtemp" ]]
then
else
MINHEAP=$MINHEAPtemp
fi
if [[ -z "$OPTIONStemp" ]]
then
else
OPTIONS=$OPTIONStemp
fi
 as_user() {
   if [ "$ME" = "$USERNAME" ] ; then
     bash -c "$1"
   else
     su - "$USERNAME" -c "$1"
   fi
 }
  ME=`whoami`
 echo 'Done Configurating Functions'
 java -version
 core () {if [[$ENABLEUPDATE = 'true']]
 then
 update
 fi
 java -Xmx${MAXHEAP} -Xms${MINHEAP} -XX:+UseConcMarkSweepGC \
 -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts \
 -jar $SERVICE $OPTIONS
 }
command() {
   command="$1";
   if pgrep -u $USERNAME -f $SERVICE > /dev/null
   then
     pre_log_len=`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`
     echo "$SERVICE is running... executing command"
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"$command\"\015'"
     sleep .1 # assumes that the command will run and print to the log file in less than .1 seconds
     # print output
     tail -n $[`wc -l "$MCPATH/logs/latest.log" | awk '{print $1}'`-$pre_log_len] "$MCPATH/logs/latest.log"
   fi
 }
stop() {
   if pgrep -u $USERNAME -f $SERVICE > /dev/null
   then
     echo "Stopping $SERVICE"
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"say SERVER SHUTTING DOWN IN 10 SECONDS. Saving map...\"\015'"
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"save-all\"\015'"
     sleep 10
     as_user "screen -p 0 -S minecraft -X eval 'stuff \"stop\"\015'"
     sleep 7
   else
     echo "$SERVICE was not running."
   fi
   if pgrep -u $USERNAME -f $SERVICE > /dev/null
   then
     echo "Error! $SERVICE could not be stopped."
   else
     echo "$SERVICE is stopped."
   fi
 } 
startloop () { 
echo 'Starting the server...'
 while [ condition ]
do
core
	echo -e " You have $timelimit seconds\n Stop it quickly or It will Restart... \c"
stop=""
read -t $timelimit stop
#read -t $timelimit name <&1
# for bash versions bellow 3.x
if [ ! -z "$stop" ]
then
echo -e "Stopping..."
exit
else
echo -e "\n TIME OUT\n Restarting Server..."
fi 
done
 }
start () {
if [[$RESTARTCRASH = 'true']] then
cd $DIR
startloop
else
cd $DIR
core
fi
}
 update () { echo 'fetching version data...'
 wget https://launchermeta.mojang.com/mc/game/version_manifest.json -O json.txt
 $a='http://s3.amazonaws.com/Minecraft.Download/versions/'
 $b'/minecraft_server.'
 $c='.jar'
 echo 'Reading Json data...'
 if [[$UPDATE = 'snapshot']]
 then
 version=$(cat json.txt | jq '.latest.snapshot')
 if [[$currentversion = $version]]
 then
 else
 wget $a$version$b$version$c -O $SERVICE
 echo 'currentversion='$version > 'currentversion.sh'
 fi
 fi
 if [[$UPDATE = 'release']]
 then
 version=$(cat json.txt | jq '.latest.release')
 if [[$currentversion = $version]]
 then
 else
 wget $a$version$b$version$c -O $SERVICE
 echo 'currentversion='$version > 'currentversion.sh'
 fi
 fi
 }
 start
