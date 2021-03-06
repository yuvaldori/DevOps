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
echo "PACKAGER_REPOS_LIST=$PACKAGER_REPOS_LIST"
echo "CREATE_VAGRANT_BOX=$CREATE_VAGRANT_BOX"
echo "CREATE_DOCKER_IMAGES=$CREATE_DOCKER_IMAGES"


if [ "$PACK_CORE" == "yes" ] || [ "$PACK_AGENT" == "yes" ] || [ "$yaml_spec_updater" == "yes" ] || [ "$CREATE_VAGRANT_BOX" == "yes" ] || [ "$CREATE_DOCKER_IMAGES" == "yes" ]
then
	REPOS_LIST=$CORE_REPOS_LIST
fi
if [ "$PACK_CLI" == "yes" ] || [ "$yaml_spec_updater" == "yes" ] || [ "$CREATE_VAGRANT_BOX" == "yes" ] || [ "$CREATE_DOCKER_IMAGES" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$CLI_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ] || [ "$yaml_spec_updater" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$UI_REPOS_LIST
fi
if [ "$PACK_CORE" == "yes" ] || [ "$PACK_UI" == "yes" ] || [ "$PACK_AGENT" == "yes" ] || [ "$yaml_spec_updater" == "yes" ] || [ "$CREATE_VAGRANT_BOX" == "yes" ] || [ "$CREATE_DOCKER_IMAGES" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$PACKAGER_REPOS_LIST
fi



echo "REPOS_LIST=$REPOS_LIST"

echo "### Repositories list: $REPOS_LIST"

for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"
	
	TAG_NAME=$(get_version_name $r $core_tag_name $plugins_tag_name)
	VERSION_BRANCH_NAME=$TAG_NAME"-build"
	
	pushd $r
		
		echo "TAG_NAME=$TAG_NAME"
		echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
		
		# recreate tag locally
		git tag -d $TAG_NAME
		exit_on_error
		
        	git tag -f $TAG_NAME
        	exit_on_error
        	
        	# delete existing tag from remote - we must delete the old tag in order to make travis to run the tests on tags.
        	##git push --delete origin tag
        	git push origin :refs/tags/$TAG_NAME
        	exit_on_error
        	
        	# push tag to remote
		git push -f origin tag $TAG_NAME
		exit_on_error
		
		#if [ "$RELEASE_BUILD" == "false" ]
		#then
			#git checkout $BRANCH_NAME
			#exit_on_error
			#if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
	 		#then
	 			#echo "deleting nightly build branch"
	 			#git branch -D $VERSION_BRANCH_NAME
	 			#exit_on_error
	 		#fi
	 		#if [[ `git branch -v -a | grep remotes/origin/$VERSION_BRANCH_NAME` ]]
	 		#then
	 			#git push origin --delete $VERSION_BRANCH_NAME
	 			#if [ $? != 0 ] ; then
			         	#git fetch origin --prune
			         	#exit_on_error
			      	#fi
	 			#In case of failure:
	 			##git remote prune origin --dry-run (shows you what would be deleted)
	 			##git fetch origin --prune (remove deleted branches)
	 		#fi
	 	#fi

  	popd
done
