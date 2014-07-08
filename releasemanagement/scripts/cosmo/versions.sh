#!/bin/bash -x

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		exit 1
      fi

}
function  get_product_version_for_pypi {
      case "$MILESTONE" in
	        ga)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION
	            ;;
	         
	        rc)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION$MILESTONE"1"
	            ;;
	         
	        
	        *)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION`echo "$MILESTONE" | sed -r 's/m/a/'`
	 
	esac

}
function  get_product_version_for_npm {
	case "$MILESTONE" in
	        ga)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION
	            ;;
	         
	        rc)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION$MILESTONE"1"
	            ;;
	         
	        
	        *)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"-"$MILESTONE
	 
	esac

}

echo "PACK_CLI=$PACK_CLI"
echo "PACK_CORE=$PACK_CORE"
echo "PACK_UI=$PACK_UI"
echo "MANAGER_SHA=$MANAGER_SHA"
echo "CLI_SHA=$CLI_SHA"
echo "UI_SHA=$UI_SHA"
echo "MAJOR_VERSION=$MAJOR_VERSION"
echo "MINOR_VERSION=$MINOR_VERSION"
echo "SERVICEPACK_VERSION=$SERVICEPACK_VERSION"
echo "SERVICEPACK_VERSION=$SERVICEPACK_VERSION"
echo "MILESTONE=$MILESTONE"

if [ "$PACK_CLI" == "yes" ]
then
	REPOS_LIST="cloudify-cli/cosmo_cli "
fi
if [ "$PACK_CORE" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST"cloudify-manager/rest-service/manager_rest "
fi
if [ "$PACK_UI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST"cosmo-ui"
fi

echo "REPOS_LIST=$REPOS_LIST"

echo "### Repositories list: $REPOS_LIST"

for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"
	pushd $r
		if [[ `git branch | grep temp_version` ]]
	 	then
	 		echo "Branch named temp_version already exists, deleting it"
	 		git branch -D temp_version
	 		exit_on_error
	 	fi
	 	git checkout -b temp_version
	 	exit_on_error
		
		#set revision sha
		if [ "$r" == "cloudify-manager/rest-service/manager_rest" ]
		then
			REVISION=$MANAGER_SHA
		elif [ "$r" == "cloudify-cli/cosmo_cli" ]
		then
			REVISION=$CLI_SHA
		elif [ "$r" == "cosmo-ui" ]
		then
			REVISION=$UI_SHA	
		fi
		#set product version
		if [ "$r" == "cosmo-ui" ]
		then
			get_product_version_for_npm
		else
			get_product_version_for_pypi
		fi
		
		DATE=`date +"%d/%m/%Y-%T"`
		
	  	echo '{' > VERSION
	  	echo '    "version": "'$PRODUCT_VERSION'",' >> VERSION
	  	echo '    "build": "'$BUILD_NUM'",' >> VERSION
	  	echo '    "date": "'$DATE'",' >> VERSION
	  	echo '    "commit": "'$REVISION'"' >> VERSION
	  	echo '}' >> VERSION
	  	
	  	git commit -m 'edit VERSION file by nightly build' VERSION
	  	exit_on_error
  	popd
done
