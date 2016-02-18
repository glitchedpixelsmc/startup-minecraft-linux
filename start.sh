#!/bin/bash
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
 echo 'Starting the Big Guy...'
 java -version
start () { cd $DIR &&  }
