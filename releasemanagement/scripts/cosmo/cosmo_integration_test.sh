#!/bin/bash

source retry.sh

echo "### PATH is: $PATH"
report_dir=`pwd`/xunit_reports

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

REPOS_LIST="cloudify-dsl-parser cloudify-rest-client cloudify-plugins-common cloudify-cli \
cloudify-manager/plugins/plugin-installer cloudify-manager/rest-service cloudify-bash-plugin"

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

	popd
done	

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
		
		#Preparation
		sudo /etc/init.d/rabbitmq-server start
		export PATH=/usr/share/elasticsearch/bin:$PATH
		sudo mkdir -p /usr/share/elasticsearch/data
		sudo chmod 777 /usr/share/elasticsearch/data
		sudo ln -s /usr/local/bin/gunicorn /usr/bin/gunicorn
		sudo ln -s /usr/local/bin/gunicorn /usr/bin/gunicorn

		nosetests -s -v workflow_tests --with-xunit --xunit-file=$report_dir/xunit-integration-tests.xml
		retval=$?
		echo "### Integration tests exited with code $retval"
		if [ $retval != 0 ]; then
			echo "### Script ended with exit code $retval"
        		exit $retval
		fi
	popd	

popd


