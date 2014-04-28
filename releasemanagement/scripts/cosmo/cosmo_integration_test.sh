#!/bin/bash

source retry.sh
	
echo "### PATH is: $PATH"
report_dir='pwd'/xunit_reports

#echo "### Running rvm use 2.1.0"
#rvm use 2.1.0

echo "### which unicorn"
which unicorn
which ruby
ruby --version

echo "### Creating virtualenv"
rm -rf env
virtualenv env
echo "### Activating virtualenv"
source env/bin/activate

echo "### Installing nose"
retry "pip install nose"

echo "### Installing protobuf using easy_install"
easy_install protobuf	

pushd cloudify-manager

	pushd workflow-service
		echo "### Running bundle install for workflow-service"
		bundle install
	popd
	
	pushd rest-service
		echo "### Installing manager-rest dependencies"
		retry "pip install . --process-dependency-links"
		if [ $? != 0 ]; then
			exit $?
		fi
	popd

	pushd tests
		echo "### Installing integration tests dependencies"
		retry "pip install . --process-dependency-links"
		if [ $? != 0 ]; then
			exit $?
		fi
		echo "### Running integration tests"
		nosetests -s -v workflow_tests --with-xunit --xunit-file=$report_dir/xunit-integration-tests.xml
		retval=$?
		echo "### Integration tests exited with code $retval"
		if [ $retval != 0 ]; then
			echo "### Script ended with exit code $retval"
        		exit $retval
		fi
	popd	

popd


