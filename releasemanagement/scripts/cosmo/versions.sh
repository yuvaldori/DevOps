#!/bin/bash -x

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
done
