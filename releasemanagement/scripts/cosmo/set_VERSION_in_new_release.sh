#!/bin/bash -x

echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
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

source generic_functions.sh

for r in ${FULL_REPOS}
do
	echo "### Processing repository: $r"
	pushd $r
		
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
	  	echo '    "build": "",' >> VERSION
	  	echo '    "date": "",' >> VERSION
	  	echo '    "commit": ""' >> VERSION
	  	echo '}' >> VERSION

	  	git add VERSION
	  	git commit -m 'edit VERSION file in new release by quickbuild' VERSION
	  	exit_on_error
	  

  	popd
done
