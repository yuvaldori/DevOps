#!/bin/bash -x

source retry.sh

fail_file=cosmo_i_tests_fail.log
rm -f $fail_file

#Preparation
sudo /etc/init.d/rabbitmq-server start
export PATH=/usr/share/elasticsearch/bin:$PATH
sudo mkdir -p /usr/share/elasticsearch/data
sudo chmod 777 /usr/share/elasticsearch/data
sudo ln -s /usr/local/bin/gunicorn /usr/bin/gunicorn
sudo ln -s /usr/local/bin/gunicorn /usr/bin/gunicorn

echo "### PATH is: $PATH"

report_file="$(pwd)/xunit_reports/xunit-integration-tests.xml"
if [ ! -d "$(pwd)/xunit_reports/" ]; then
  echo "creating report directory"
  mkdir "$(pwd)/xunit_reports/"
fi

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
		
		retry "pip install . -r dev-requirements.txt"
		retval=$?
		if [ $retval -ne 0 ]; then
			echo "### Installation for package [$r] exited with code $retval"
			exit $retval
		fi
		
	popd
done	

pushd cloudify-manager

	pushd rest-service
		echo "### Installing manager-rest dependencies"
		retry "pip install . -r dev-requirements.txt"
		if [ $? != 0 ]; then
			echo "fail" > $fail_file
			exit $?
		fi
	popd

	pushd tests
		echo "### Installing integration tests dependencies"
		retry "pip install ."
		if [ $? != 0 ]; then
			echo "fail" > $fail_file
			exit $?
		fi
		echo "### Running integration tests"		
		
		nosetests -s -v workflow_tests --with-xunit --xunit-file=$report_file
		#nosetests -s -v workflow_tests --nologcapture --nocapture
		retval=$?
		echo "### Integration tests exited with code $retval"
		if [ $retval != 0 ]; then
			echo "### Script ended with exit code $retval"
			echo "fail" > $fail_file
        		exit $retval
		fi
	popd	

popd


