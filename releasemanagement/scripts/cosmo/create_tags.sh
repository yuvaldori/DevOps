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
echo "PRODUCT_VERSION_FULL=$PRODUCT_VERSION_FULL"
echo "BUILD_NUM=$BUILD_NUM"


if [ "$PACK_CORE" == "yes" ]
then
	defaults_config_yaml_file_name="cloudify-config.defaults.yaml"
	defaults_config_yaml_file="cloudify-openstack-provider/cloudify_openstack/"$defaults_config_yaml_file_name
	config_yaml_file_name="cloudify-config.yaml"
	config_yaml_file="cloudify-openstack-provider/cloudify_openstack/"$config_yaml_file_name
	defaults_cli_config_yaml_file_name="cloudify-config.defaults.yaml"
	defaults_cli_config_yaml_file="cloudify-cli/cloudify_simple_provider/"$defaults_cli_config_yaml_file_name
	config_cli_yaml_file_name="cloudify-config.yaml"
	config_cli_yaml_file="cloudify-cli/cloudify_simple_provider/"$config_cli_yaml_file_name
	

	#components_package_url=$(grep "cloudify_components_package_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_components_package_url: //')
	#core_package_url=$(grep "cloudify_core_package_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_core_package_url: //')
	#ui_package_url=$(grep "cloudify_ui_package_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_ui_package_url: //')
	#ubuntu_agent_url=$(grep "cloudify_ubuntu_agent_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_ubuntu_agent_url: //')
	#windows_agent_url=$(grep "cloudify_windows_agent_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_windows_agent_url: //')
	if [ "$RELEASE_BUILD" == "false" ]
	then
		components_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-components_amd64.deb"
		core_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-core_amd64.deb"
		ubuntu_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ubuntu-agent_amd64.deb"
		centos_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-centos-agent_amd64.deb"
		windows_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-windows-agent_amd64.deb"
		ui_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-ui_amd64.deb"
	else
		ui_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.0.0/nightly_"$BUILD_NUM"/cloudify-ui_"$PRODUCT_VERSION_FULL"_amd64.deb"
		core_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.0.0/nightly_"$BUILD_NUM"/cloudify-core_"$PRODUCT_VERSION_FULL"_amd64.deb"
		ubuntu_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.0.0/nightly_"$BUILD_NUM"/cloudify-ubuntu-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
		centos_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.0.0/nightly_"$BUILD_NUM"/cloudify-centos-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
		windows_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.0.0/nightly_"$BUILD_NUM"/cloudify-windows-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
		components_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.0.0/nightly_"$BUILD_NUM"/cloudify-components_"$PRODUCT_VERSION_FULL"_amd64.deb"
	fi

	sed -i "s|{{ components_package_url }}|$(echo ${components_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|{{ core_package_url }}|$(echo ${core_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|{{ ui_package_url }}|$(echo ${ui_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|{{ ubuntu_agent_url }}|$(echo ${ubuntu_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|{{ windows_agent_url }}|$(echo ${windows_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|{{ centos_agent_url }}|$(echo ${centos_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	 
        pushd cloudify-openstack-provider/cloudify_openstack
		git commit -m 'replace urls in config yaml files' $defaults_config_yaml_file_name $config_yaml_file_name $defaults_cli_config_yaml_file_name $config_cli_yaml_file_name
	popd
	REPOS_LIST="cloudify-bash-plugin cloudify-dsl-parser cloudify-plugin-template cloudify-manager \
	cloudify-rest-client cloudify-system-tests cloudify-plugins-common cloudify-chef-plugin \
	cloudify-openstack-plugin cloudify-openstack-provider cloudify-python-plugin cloudify-packager-ubuntu packman \
	cloudify-puppet-plugin cloudify-cli cloudify-examples cloudify-nodecellar-openstack cloudify-packager-centos"
fi
#$PACK_CLI" == "yes" ]
#then
#	REPOS_LIST=$REPOS_LIST"cloudify-cli "
#fi
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
		TAG_NAME="nightly"
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
			cloudify-packager-ubuntu|packman|cloudify-packager-centos)	
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
