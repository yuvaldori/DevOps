#!/bin/bash

source retry.sh

if [ "$PACK_CLI" = "yes" ]
then
	REPOS_LIST="cloudify-cli/cosmo_cli "
fi
if [ "$PACK_CORE" = "yes" ]
then
	REPOS_LIST=$REPOS_LIST"cloudify-manager/rest-service/manager_rest "
fi
if [ "$PACK_UI" = "yes" ]
then
	REPOS_LIST=$REPOS_LIST"cosmo-ui"
fi

echo "REPOS_LIST

echo "### Repositories list: $REPOS_LIST"

for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"	   	
	#if [[ `git branch | grep temp_version` ]]
	#then
	    #echo "Branch named temp_version already exists, deleting it"
	    #git branch -d temp_version
	#fi
	#set revision sha
	if [ "$r" = "cloudify-manager/rest-service/manager_rest" ]
	then
		REVISION=$MANAGER_SHA
	elif [ "$r"="cloudify-cli/cosmo_cli" ]
	then
		REVISION=$CLI_SHA
	elif [ "$r" = "cosmo-ui" ]
	then
		REVISION=$UI_SHA	
	fi
	pushd $r
	  	echo '{' > VERSION
  		echo '    "version": "'$PRODUCT_VERSION'",' >> VERSION
  		echo '    "build": "'$BUILD_NUM'",' >> VERSION
  		echo '    "date": "'`date +'%d/%m/%Y'`'",' >> VERSION
  		echo '    "commit": "'$REVISION'"' >> VERSION
  		echo '}' >> VERSION
  	popd
  	##git checkout -b temp_version
	##git commit -m 'edit VERSION by nightly'
	#result=`echo $?`
	#echo "### Nosetests exited with code $result"
        #if [ $result -ne 0 ]; then
	#	cosmo_unit_tests_fail="$r,$cosmo_unit_tests_fail"			
   	#	echo "### Unit tests failed for: $r";   			
	#fi
done
