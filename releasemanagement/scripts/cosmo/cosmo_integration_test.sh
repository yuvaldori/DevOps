#!/bin/bash

#export PATH=${PATH}:/usr/share/elasticsearch/bin:$HOME/.rvm/bin:$HOME/.rvm/gems/ruby-2.1.0/bin
#source ~/.bashrc	
echo "### PATH is: $PATH"

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
pip install nose

echo "### Installing protobuf using easy_install"
easy_install protobuf	

pushd cosmo-manager

	pushd workflow-service
		echo "### Running bundle install for workflow-service"
		bundle install
	popd
	
	pushd manager-rest
		echo "### Installing manager-rest dependencies"
		pip install . --process-dependency-links
		if [ $? != 0 ]; then
			exit $?
		fi
	popd

	pushd workflows
		echo "### Installing integration tests dependencies"
		pip install . --process-dependency-links
		if [ $? != 0 ]; then
			exit $?
		fi
		echo "### Running integration tests"
		nosetests -s -v workflow_tests
		retval=$?
		echo "### Integration tests exited with code $retval"
		if [ $retval != 0 ]; then
			echo "### Script ended with exit code $retval"
        		exit $retval
		fi
	popd	

popd


