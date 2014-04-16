#!/bin/bash

source retry.sh

fail_file=cosmo_unit_tests_fail.log
report_dir=/opt/buildagent/workspace/root/cosmo/trunk/CI/NightlyBuild/xunit_reports

# Order is important!
#REPOS_LIST="cloudify-dsl-parser cloudify-rest-client cloudify-plugins-common cloudify-cli \
#cloudify-manager/plugins/plugin-installer cloudify-manager/rest-service cloudify-bash-plugin"

echo "### Repositories list: $REPOS_LIST"

echo "### Creating vitualenv"
# Erase previous env before and not after so that in a case of failure we'll have the previous env
rm -rf env
virtualenv env

echo "### Activating vitualenv"
source env/bin/activate

echo "### Installing flake8"
retry "pip install flake8"

echo "### Installing nose"
retry "pip install nose"

echo "### Upgrading to latest pip"
retry "pip install --upgrade pip"

# There's an issue with protobuf installation using pip
echo "### Installing protobuf using easy_install"
easy_install protobuf

echo "### Running tests"

for r in ${REPOS_LIST}
do
     		
	echo "### Processing repository: $r"	   	
	
	pushd $r

	echo "### Installing [$r] dependencies"
	if [ "$r" = "cloudify-plugins-common" ]
	then
		retry "python setup.py install"
		retval=$?
		if [ $retval -ne 0 ]; then
			echo "### Installation for package [$r] exited with code $retval"
			exit $retval
		fi
	else
 		retry "pip install . --process-dependency-links"
		retval=$?
		if [ $retval -ne 0 ]; then
			echo "### Installation for package [$r] exited with code $retval"
			exit $retval
		fi
	fi
		
	echo "### Running flake8 for: $r"
	flake8 .
	echo "### flake8 exited with code $?"

	echo "### Running nosetests for: $r"
	if [ "$r" = "cloudify-manager/plugins/agent-installer" ]
	then
		nosetests worker_installer/tests/test_worker_installer.py:TestLocalInstallerCase --nologcapture --nocapture --with-xunit --xunit-file=$report_dir/xunit-cloudify-manager-agent-installer.xml
	elif [ "$r" = "cloudify-manager/rest-service" ]
	then
  		nosetests . --nologcapture --nocapture --with-xunit --xunit-file=$report_dir/xunit-cloudify-manager-rest-service.xml
	else
		nosetests . --nologcapture --nocapture --with-xunit --xunit-file=$report_dir/xunit-$r.xml
	fi

	result=`echo $?`
	echo "### Nosetests exited with code $result"
        if [ $result -ne 0 ]; then
		cosmo_unit_tests_fail="$r,$cosmo_unit_tests_fail"			
   		echo "### Unit tests failed for: $r";   			
	fi
	
	popd
	
	rm -f $fail_file	
	#cat </dev/null>$fail_file
	if [ ! -z $cosmo_unit_tests_fail ]
	then
		echo "### cosmo_unit_tests_fail=$cosmo_unit_tests_fail"
		echo "$cosmo_unit_tests_fail" > $fail_file 
	fi
  	
done

deactivate
