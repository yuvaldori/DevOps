#!/bin/bash

#DIR="/dev/shm/quickbuild/workspace/root/xap/trunk/GigaSpaces/Java"
DIR="`pwd`"

LOG_FILE=${DIR}/replace_pom_version.log
echo "*** Update pom.xml with previous version ***" >> $LOG_FILE
find "${DIR}" -type f -not \( -name .svn -a -prune \) -name 'pom.xml' |
while read fname
do
	grep "10.0.0-SNAPSHOT" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/10.0.0-SNAPSHOT/9.7.0-SNAPSHOT/g" "$fname"
	#sed -i "s/9.7.0-SNAPSHOT/10.0.0-SNAPSHOT/g" "$fname"		
       svn commit -m 'update pom.xml to previous version 9.7.0' "$fname"	
done