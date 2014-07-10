#!/bin/bash -x

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
#RELEASE_BUILD="true"
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
echo "RELEASE_BUILD=$RELEASE_BUILD"
echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
echo "cloudify_bash_majorVersion=$cloudify_bash_majorVersion"
echo "cloudify_chef_majorVersion=$cloudify_chef_majorVersion"
echo "cloudify_openstack_plugin_majorVersion=$cloudify_openstack_plugin_majorVersion"
echo "cloudify_openstack_provider_majorVersion=$cloudify_openstack_provider_majorVersion"
echo "cloudify_python_majorVersion=$cloudify_python_majorVersion"
echo "cloudify_puppet_majorVersion=$cloudify_puppet_majorVersion"
echo "cloudify_packager_majorVersion=$cloudify_packager_majorVersion"
echo "core_tag_name=$core_tag_name"

if [ "$PACK_CORE" == "yes" ]
then
	REPOS_LIST="cloudify-bash-plugin cloudify-dsl-parser cloudify-plugin-template cloudify-manager cloudify-rest-client cloudify-system-tests cloudify-plugins-common cloudify-chef-plugin cloudify-openstack-plugin cloudify-openstack-provider cloudify-python-plugin cloudify-packager-ubuntu cloudify-cli packman cloudify-puppet-plugin "
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
	if [ "$RELEASE_BUILD" == "false" ]
	then
		TAG_NAME = "nightly"
	else
		case "$r" in
			cloudify-bash-plugin)
				TAG_NAME=$cloudify_bash_majorVersion
				;;			 
			cloudify-chef-plugin)
				TAG_NAME=$cloudify_chef_majorVersion
				;;			 
			cloudify-openstack-plugin)
				TAG_NAME=$cloudify_openstack_plugin_majorVersion
				;;
			cloudify-openstack-provider)
				TAG_NAME=$cloudify_openstack_provider_majorVersion				
				;;
			cloudify-python-plugin)
				TAG_NAME=$cloudify_python_majorVersion
				;;
			cloudify-puppet-plugin)
				TAG_NAME=$cloudify_puppet_majorVersion
				;;
			cloudify-packager-ubuntu|packman)	
				TAG_NAME=$cloudify_packager_majorVersion
				;;			 
			*)
				TAG_NAME=$core_tag_name	 
		esac
	fi
	pushd $r
		
		echo "TAG_NAME=$TAG_NAME"
		git tag -d $TAG_NAME
		git push origin :$TAG_NAME
		#git checkout $VERSION_BRANCH_NAME
        	git tag $TAG_NAME
		git push origin tag $TAG_NAME
		git checkout $BRANCH_NAME
		
		if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
	 	then
	 		echo "Branch named $VERSION_BRANCH_NAME already exists, deleting it"
	 		git branch -D $VERSION_BRANCH_NAME
	 		exit_on_error
	 		git push origin --delete $VERSION_BRANCH_NAME
	 	fi		
	 		
		

  	popd
done
