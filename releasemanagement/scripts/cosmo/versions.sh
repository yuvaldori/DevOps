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
	         
	        rc1)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION$MILESTONE
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
	         
	        rc1)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"-"$MILESTONE
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
echo "OS_PLUGIN_SHA=$OS_PLUGIN_SHA"
echo "BASH_PLUGIN_SHA=$BASH_PLUGIN_SHA"
echo "CHEF_PLUGIN_SHA=$CHEF_PLUGIN_SHA"
echo "PUPPET_PLUGIN_SHA=$PUPPET_PLUGIN_SHA"
echo "MAJOR_VERSION=$MAJOR_VERSION"
echo "MINOR_VERSION=$MINOR_VERSION"
echo "SERVICEPACK_VERSION=$SERVICEPACK_VERSION"
echo "MILESTONE=$MILESTONE"
echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
echo "RELEASE_BUILD=$RELEASE_BUILD"


if [ "$PACK_CLI" == "yes" ]
then
	REPOS_LIST="cloudify-cli/cosmo_cli "
fi
if [ "$PACK_CORE" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST"cloudify-manager/rest-service/manager_rest cloudify-openstack-plugin/nova_plugin cloudify-puppet-plugin/puppet_plugin cloudify-chef-plugin/chef_plugin cloudify-bash-plugin/bash_runner "
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
		if [[ "$MILESTONE" == "ga" && "$RELEASE_BUILD" == "true" ]]
		then
			echo "ga release branch name is: "`git branch`	
		else
			if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
	 		then
	 			echo "Branch named $VERSION_BRANCH_NAME already exists, deleting it"
	 			git branch -D $VERSION_BRANCH_NAME
	 			exit_on_error
	 			git push origin --delete $VERSION_BRANCH_NAME
	 		fi		
	 		git checkout -b $VERSION_BRANCH_NAME
	 		exit_on_error
		fi
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
		elif [ "$r" == "cloudify-openstack-plugin/nova_plugin" ]
		then
			REVISION=$OS_PLUGIN_SHA
		elif [ "$r" == "cloudify-puppet-plugin/puppet_plugin" ]
		then
			REVISION=$PUPPET_PLUGIN_SHA
		elif [ "$r" == "cloudify-chef-plugin/chef_plugin" ]
		then
			REVISION=$CHEF_PLUGIN_SHA
		elif [ "$r" == "cloudify-bash-plugin/bash_runner" ]
		then
			REVISION=$BASH_PLUGIN_SHA
		fi
		#set product version
		#set product version
		if [ "$r" == "cosmo-ui" ]
		then
			echo "run get_product_version_for_npm"
			get_product_version_for_npm
		else
			
			case "$r" in
				'cloudify-bash-plugin/bash_runner')
					PRODUCT_VERSION=$cloudify_bash_majorVersion
					;;			 
				'cloudify-chef-plugin/chef_plugin')
					PRODUCT_VERSION=$cloudify_chef_majorVersion
					;;			 
				'cloudify-openstack-plugin/nova_plugin')
					PRODUCT_VERSION=$cloudify_openstack_plugin_majorVersion
					;;				
				'cloudify-puppet-plugin/puppet_plugin')
					PRODUCT_VERSION=$cloudify_puppet_majorVersion
					;;							 
				*)
					PRODUCT_VERSION=$core_tag_name	 
			esac
		fi

		#PRODUCT_VERSION=`echo "$PRODUCT_VERSION" | sed -r 's/m/a/'`
		DATE=`date +"%d/%m/%Y-%T"`
		
	  	echo '{' > VERSION
	  	echo '    "version": "'$PRODUCT_VERSION'",' >> VERSION
	  	echo '    "build": "'$BUILD_NUM'",' >> VERSION
	  	echo '    "date": "'$DATE'",' >> VERSION
	  	echo '    "commit": "'$REVISION'"' >> VERSION
	  	echo '}' >> VERSION
	  	
	  	git add VERSION
	  	git commit -m 'edit VERSION file by nightly build' VERSION
	  	exit_on_error
	  	#if [[ "$MILESTONE" == "ga" && "$RELEASE_BUILD" == "true" ]]
		#then
	  		#git push --force origin master
			#exit_on_error
		#else
			#git push --force origin $VERSION_BRANCH_NAME
			#exit_on_error	
		#fi
	  	
  	popd
done
