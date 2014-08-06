#!/bin/bash -x

source generic_functions.sh


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
echo "CORE_REPOS_LIST=$CORE_REPOS_LIST"
echo "UI_REPOS_LIST=$UI_REPOS_LIST"
echo "CLI_REPOS_LIST=$CLI_REPOS_LIST"
echo "PRODUCT_VERSION_FULL=$PRODUCT_VERSION_FULL"


if [ "$PACK_CLI" == "yes" ]
then
	FULL_REPOS=$CLI_REPOS_LIST
fi
if [ "$PACK_CORE" == "yes" ]
then
	FULL_REPOS=$FULL_REPOS" "$CORE_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ]
then
	FULL_REPOS=$FULL_REPOS" "$UI_REPOS_LIST
fi

echo "FULL_REPOS= $FULL_REPOS"

echo "### Repositories list: $FULL_REPOS"
for r in ${FULL_REPOS}
do
	echo "### Processing repository: $r"
	pushd $r
		if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
 		then
 			echo "Branch named $VERSION_BRANCH_NAME already exists, deleting it"
 			git branch -D $VERSION_BRANCH_NAME
 			exit_on_error
 			git push origin --delete $VERSION_BRANCH_NAME
 		fi		
 		git checkout -b $VERSION_BRANCH_NAME
 		exit_on_error
 		git checkout master
		exit_on_error
 	popd
	
done


if [[ "$PACK_CORE" == "yes" ||  "$PACK_CLI" == "yes" ]]
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
		ui_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE"-RELEASE/cloudify-ui_"$PRODUCT_VERSION_FULL"_amd64.deb"
		core_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-core_"$PRODUCT_VERSION_FULL"_amd64.deb"
		ubuntu_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-ubuntu-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
		centos_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-centos-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
		windows_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-windows-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
		components_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-components_"$PRODUCT_VERSION_FULL"_amd64.deb"
	fi

	#sed -i "s|{{ components_package_url }}|$(echo ${components_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	#sed -i "s|{{ core_package_url }}|$(echo ${core_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	#sed -i "s|{{ ui_package_url }}|$(echo ${ui_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	#sed -i "s|{{ ubuntu_agent_url }}|$(echo ${ubuntu_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	#sed -i "s|{{ windows_agent_url }}|$(echo ${windows_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	#sed -i "s|{{ centos_agent_url }}|$(echo ${centos_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	
	
	sed -i "s|components_package_url:.*|components_package_url: $(echo ${components_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|core_package_url:.*|core_package_url: $(echo ${core_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|ui_package_url:.*|ui_package_url: $(echo ${ui_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|ubuntu_agent_url:.*|ubuntu_agent_url: $(echo ${ubuntu_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|windows_agent_url:.*|windows_agent_url: $(echo ${windows_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	sed -i "s|centos_agent_url:.*|centos_agent_url: $(echo ${centos_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file
	
	
	#OS_PROVIDER_SHA_file="OS_PROVIDER.SHA"
	#rm -f $OS_PROVIDER_SHA_file
        #pushd cloudify-openstack-provider/cloudify_openstack
        #	git add $defaults_config_yaml_file_name $config_yaml_file_name
	#	git commit -m 'replace urls in config yaml files' $defaults_config_yaml_file_name $config_yaml_file_name
	#	OS_PROVIDER_SHA=$(git rev-parse HEAD) 
	#	git push origin master
	#popd
	#CLI_SHA_file="CLI.SHA"
	#rm -f $CLI_SHA_file
	#pushd cloudify-cli/cloudify_simple_provider
	#	git add $defaults_cli_config_yaml_file_name $config_cli_yaml_file_name
	#	git commit -m 'replace urls in config yaml files' $defaults_cli_config_yaml_file_name $config_cli_yaml_file_name
	#	CLI_SHA=$(git rev-parse HEAD)
	#	git push origin master
	#popd
	#echo "$OS_PROVIDER_SHA" > $OS_PROVIDER_SHA_file
	#echo "$CLI_SHA" > $CLI_SHA_file
fi

python ./update-versions.py --repositories-dir . --cloudify-version $MAJOR_VERSION.$MINOR_VERSION$MILESTONE --plugins-version 1.1$MILESTONE --build-number 7
exit_on_error
	  	
echo "### Repositories list: $FULL_REPOS"
for r in ${FULL_REPOS}
do
	echo "### Processing repository: $r"
	pushd $r
		git add -u .
		git commit -m "Bump version to $MAJOR_VERSION.$MINOR_VERSION$MILESTONE / 1.1$MILESTONE"
		git push origin master
 		git checkout $VERSION_BRANCH_NAME
 		exit_on_error
 	popd
	
done	  	
  	
