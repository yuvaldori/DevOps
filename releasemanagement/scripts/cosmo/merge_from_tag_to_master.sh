#!/bin/bash -x

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		exit 1
      fi

}
 
cloudify_bash_majorVersion=1.0
cloudify_chef_majorVersion=1.0
cloudify_openstack_plugin_majorVersion=1.0
cloudify_openstack_provider_majorVersion=1.0
cloudify_python_majorVersion=1.0
cloudify_puppet_majorVersion=1.0
cloudify_packager_majorVersion=1.0
core_tag_name=3.0
#CORE_REPOS_LIST="cloudify-bash-plugin cloudify-dsl-parser cloudify-plugin-template cloudify-manager cloudify-rest-client cloudify-system-tests cloudify-plugins-common cloudify-chef-plugin cloudify-openstack-plugin cloudify-python-plugin cloudify-packager-ubuntu packman cloudify-puppet-plugin cloudify-examples cloudify-nodecellar-openstack cloudify-packager-centos"
#UI_REPOS_LIST="cosmo-ui"
#CLI_REPOS_LIST="cloudify-cli cloudify-cli-packager cloudify-openstack-provider"

git_merge="yes"
CORE_REPOS_LIST="cloudify-packager-centos"


echo "CORE_REPOS_LIST=$CORE_REPOS_LIST"
echo "UI_REPOS_LIST=$UI_REPOS_LIST"
echo "CLI_REPOS_LIST=$CLI_REPOS_LIST"
echo "PRODUCT_VERSION_FULL=$PRODUCT_VERSION_FULL"
echo "cloudify_bash_majorVersion=$cloudify_bash_majorVersion"
echo "cloudify_chef_majorVersion=$cloudify_chef_majorVersion"
echo "cloudify_openstack_plugin_majorVersion=$cloudify_openstack_plugin_majorVersion"
echo "cloudify_openstack_provider_majorVersion=$cloudify_openstack_provider_majorVersion"
echo "cloudify_python_majorVersion=$cloudify_python_majorVersion"
echo "cloudify_puppet_majorVersion=$cloudify_puppet_majorVersion"
echo "cloudify_packager_majorVersion=$cloudify_packager_majorVersion"
echo "core_tag_name=$core_tag_name"
	
FULL_REPOS=$CORE_REPOS_LIST" "$UI_REPOS_LIST" "$CLI_REPOS_LIST
echo "FULL_REPOS=$FULL_REPOS"

echo "### Repositories list: $FULL_REPOS"
for r in ${FULL_REPOS}
do
	echo "### Processing repository: $r"
	pushd $r

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
			cloudify-packager-ubuntu|packman|cloudify-packager-centos)	
				TAG_NAME=$cloudify_packager_majorVersion
				;;			 
			*)
				TAG_NAME=$core_tag_name	 
		esac
		
		if [ "$git_merge" == "yes" ]
		then
 			git checkout master
			exit_on_error
			git reset --hard origin/master
			exit_on_error
 			git merge $TAG_NAME			
			exit_on_error
		fi
		git add .
		exit_on_error
		git commit -m  'merging develop branch by the builder - release 3.0'
		exit_on_error
		git push origin master
		exit_on_error
		git tag -f $TAG_NAME
		exit_on_error
		git push origin tag $TAG_NAME
		exit_on_error
 	popd
	
done
