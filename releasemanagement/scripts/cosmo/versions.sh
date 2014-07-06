#!/bin/bash

source retry.sh


REPOS_LIST="cloudify-manager/rest-service/manager_rest \
cloudify-cli/cosmo_cli"

echo "### Repositories list: $REPOS_LIST"

for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"	   	

	pushd $r
	  	echo '{' > VERSION
  		echo '    "version": "'$REVISION'",' >> VERSION
  		echo '    "build": "'$BUILD_NUM'",' >> VERSION
  		echo '    "date": "'`date +'%d/%m/%Y'`'",' >> VERSION
  		echo '    "commit": "'$CONFIGURATION_NAME'"' >> VERSION
  		echo '}' >> VERSION
  	popd
	
	result=`echo $?`
	echo "### Nosetests exited with code $result"
        if [ $result -ne 0 ]; then
		cosmo_unit_tests_fail="$r,$cosmo_unit_tests_fail"			
   		echo "### Unit tests failed for: $r";   			
	fi
done
