#!/bin/bash

function exit_on_error {
    status=$?
    echo "exit code="$status    
    if [ $status != 0 ] ; then
        echo "Failed (exit code $status)" 
        #exit 1
    fi

}

LOG_FILE=./update_xml_docs.log
MAJOR_OLD=10
MINOR_OLD=2
MAJOR_NEW=11
MINOR_NEW=0

echo "*** start ***" > $LOG_FILE

echo "*** Update XMLs with new version of XSDs and DTD ***" >> $LOG_FILE
find . -type f -not \( -name .git -a -prune \) -name '*.xml' -o -name '*.xsd' |
while read fname
do
	grep "dtd\/${MAJOR_OLD}_${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/dtd\/${MAJOR_OLD}_${MINOR_OLD}/dtd\/${MAJOR_NEW}_${MINOR_NEW}/g" "$fname"
	grep "schema\/${MAJOR_OLD}.${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/schema\/${MAJOR_OLD}.${MINOR_OLD}/schema\/${MAJOR_NEW}.${MINOR_NEW}/g" "$fname"
done

echo "*** Update Documentation links with new wiki space ***" >> $LOG_FILE
find . -type f -not \( -name .git -a -prune \) -name '*.html' -o -name '*.txt' -o -name '*.properties' -o -name '*.bat' -o -name '*.sh' -o -name '*.config' |
while read fname
do
	echo "*** replace display\<version> ***" >> $LOG_FILE
	grep "display\/XAP${MAJOR_OLD}${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/display\/XAP${MAJOR_OLD}${MINOR_OLD}/display\/XAP${MAJOR_NEW}${MINOR_NEW}/g" "$fname"
	### Limor Please check this part in 10.1
	echo "*** replace PLATFORM_VERSION=<version> ***" >> $LOG_FILE
	grep "PLATFORM_VERSION=${MAJOR_OLD}.${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/PLATFORM_VERSION=${MAJOR_OLD}.${MINOR_OLD}/PLATFORM_VERSION=${MAJOR_NEW}.${MINOR_NEW}/g" "$fname"
	echo "*** replace xap<version>net ***" >> $LOG_FILE
	grep "xap${MAJOR_OLD}${MINOR_OLD}net" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/xap${MAJOR_OLD}${MINOR_OLD}net/xap${MAJOR_NEW}${MINOR_NEW}net/g" "$fname"
	echo "*** replace /xap<version> ***" >> $LOG_FILE
	grep "\/xap${MAJOR_OLD}${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/\/xap${MAJOR_OLD}${MINOR_OLD}/\/xap${MAJOR_NEW}${MINOR_NEW}/g" "$fname"
	#C++ replace version in docs
	#echo "*** replace <version> ***" >> $LOG_FILE
	#grep "${MAJOR_OLD}\.${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	#sed -i "s/${MAJOR_OLD}\.${MINOR_OLD}/${MAJOR_NEW}\.${MINOR_NEW}/g" "$fname"
done

echo "*** Display git diff ***" >> $LOG_FILE
for dir in `pwd`/*/
do
      dir=${dir%*/}
      repo=${dir##*/}

      echo "### Processing repository: $repo"
      pushd $repo
      	if [ -d ".git" ]
        then
		echo "*** git diff $repo ***" >> $LOG_FILE
		git diff * >> $LOG_FILE
		#git add -u .
		#git commit -m 'Update files with new version of XSDs, DTD and wiki space'
		#git push origin master
	fi
      popd
done







