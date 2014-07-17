#!/bin/bash -x

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		exit 1
      fi

}

function  get_product_version_for_npm {
	case "$MILESTONE" in
	        ga)
	            PRODUCT_VERSION=$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION
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
echo "CORE_REPOS_LIST=$CORE_REPOS_LIST"
echo "UI_REPOS_LIST=$UI_REPOS_LIST"
echo "CLI_REPOS_LIST=$CLI_REPOS_LIST"

if [ "$PACK_CLI" == "yes" ]
then
	REPOS_LIST="cloudify-cli/cosmo_cli "
	FULL_REPOS=$CLI_REPOS_LIST
fi
if [ "$PACK_CORE" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST"cloudify-manager/rest-service/manager_rest cloudify-openstack-plugin/nova_plugin cloudify-puppet-plugin/puppet_plugin cloudify-chef-plugin/chef_plugin cloudify-bash-plugin/bash_runner "
	FULL_REPOS=$FULL_REPOS" "$CORE_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST"cosmo-ui"
	FULL_REPOS=$FULL_REPOS" "$UI_REPOS_LIST
fi

echo "REPOS_LIST= $REPOS_LIST"
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
	
	OS_PROVIDER_SHA_file="OS_PROVIDER.SHA"
	rm -f $OS_PROVIDER_SHA_file
        pushd cloudify-openstack-provider/cloudify_openstack
        	git add $defaults_config_yaml_file_name $config_yaml_file_name
		git commit -m 'replace urls in config yaml files' $defaults_config_yaml_file_name $config_yaml_file_name
		OS_PROVIDER_SHA=$(git rev-parse HEAD) 
		git push origin $VERSION_BRANCH_NAME
	popd
	CLI_SHA_file="CLI.SHA"
	rm -f $CLI_SHA_file
	pushd cloudify-cli/cloudify_simple_provider
		git add $defaults_cli_config_yaml_file_name $config_cli_yaml_file_name
		git commit -m 'replace urls in config yaml files' $defaults_cli_config_yaml_file_name $config_cli_yaml_file_name
		CLI_SHA=$(git rev-parse HEAD)
		git push origin $VERSION_BRANCH_NAME
	popd
	echo "$OS_PROVIDER_SHA" > $OS_PROVIDER_SHA_file
	echo "$CLI_SHA" > $CLI_SHA_file
fi

echo "### Repositories list: $REPOS_LIST"

for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"
	pushd $r
		
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
