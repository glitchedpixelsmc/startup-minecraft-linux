#!/bin/bash
if [ -f "conf.sh" ]
then
	echo "Hello World!"
else
	echo "MAXHEAP=1024
MINHEAP=1024
CPU_COUNT=1
SERVICE='minecraft_server.jar'
OPTIONS='nogui server'
#put snapshot or release
UPDATE='snapshot'
ENABLEUPDATE='true'" >> conf.sh
fi
echo 'Reading Configuration File'
./conf.sh
echo 'Done Reading Configuration File'
echo 'Configuring Functions'
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
start () { echo 'Starting the server...'&& cd $DIR && java -Xmx${MAXHEAP}M -Xms${MINHEAP}M -XX:+UseConcMarkSweepGC \
 -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts \
 -jar $SERVICE $OPTIONS }
 update () { echo 'fetching version data...'
 wget https://launchermeta.mojang.com/mc/game/version_manifest.json -O json.txt
 echo 'Reading Json data...'
 if [[$UPDATE = 'snapshot']]
 then
 cat json.txt | jq '.latest.snapshot'
 fi
 }
