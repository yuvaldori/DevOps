#!/bin/bash -x

source generic_functions.sh

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		exit 1
      fi

}


#PACK_CORE="yes"
#PACK_UI="yes"
#VERSION_BRANCH_NAME="temp_version"
#BRANCH_NAME="develop"
#cloudify_bash_majorVersion="1.0-rc1"
#cloudify_chef_majorVersion="1.0-rc1"
#cloudify_openstack_plugin_majorVersion="1.0-rc1"
#cloudify_openstack_provider_majorVersion="1.0-rc1"
#cloudify_python_majorVersion="1.0-rc1"
#cloudify_puppet_majorVersion="1.0-rc1"
#cloudify_packager_majorVersion="1.0-rc1"
#core_tag_name="3.0-rc1"

echo "PACK_CLI=$PACK_CLI"
echo "PACK_CORE=$PACK_CORE"
echo "PACK_UI=$PACK_UI"
echo "BRANCH_NAME=$BRANCH_NAME"
echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
echo "cloudify_bash_majorVersion=$cloudify_bash_majorVersion"
echo "cloudify_chef_majorVersion=$cloudify_chef_majorVersion"
echo "cloudify_openstack_plugin_majorVersion=$cloudify_openstack_plugin_majorVersion"
echo "cloudify_openstack_provider_majorVersion=$cloudify_openstack_provider_majorVersion"
echo "cloudify_python_majorVersion=$cloudify_python_majorVersion"
echo "cloudify_puppet_majorVersion=$cloudify_puppet_majorVersion"
echo "cloudify_packager_majorVersion=$cloudify_packager_majorVersion"
echo "core_tag_name=$core_tag_name"
echo "plugins_tag_name=$plugins_tag_name"
echo "PRODUCT_VERSION_FULL=$PRODUCT_VERSION_FULL"
echo "BUILD_NUM=$BUILD_NUM"
echo "CORE_REPOS_LIST=$CORE_REPOS_LIST"
echo "UI_REPOS_LIST=$UI_REPOS_LIST"
echo "CLI_REPOS_LIST=$CLI_REPOS_LIST"
echo "RELEASE_BUILD=$RELEASE_BUILD"


if [ "$PACK_CORE" == "yes" ]
then
	REPOS_LIST=$CORE_REPOS_LIST
fi
if [ "$PACK_CLI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$CLI_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$UI_REPOS_LIST
fi

echo "REPOS_LIST=$REPOS_LIST"

echo "### Repositories list: $REPOS_LIST"

for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"
	
	TAG_NAME=$(get_version_name $r $core_tag_name $plugins_tag_name)

	pushd $r
		
		echo "TAG_NAME=$TAG_NAME"
		VERSION_BRANCH_NAME=$TAG_NAME
        	git tag -f $TAG_NAME
        	exit_on_error
		git push origin tag $TAG_NAME
		exit_on_error
		git checkout $BRANCH_NAME
		exit_on_error
		
		if [ "$RELEASE_BUILD" == "false" ]
		then
			if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
	 		then
	 			echo "Branch named $VERSION_BRANCH_NAME already exists, deleting it"
	 			git branch -D $VERSION_BRANCH_NAME
	 			exit_on_error
	 			git push origin --delete $VERSION_BRANCH_NAME
	 			exit_on_error
	 		fi
	 	fi

  	popd
done
