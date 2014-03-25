#!/bin/bash

function retry {
   nTrys=0
   maxTrys=10
   status=256
   until [ $status == 0 ] ; do
      echo "*** Running $1"      
      $1
      status=$?
      nTrys=$(($nTrys + 1))
      if [ $nTrys -gt $maxTrys ] ; then
            echo "Number of re-trys exceeded. Exit code: $status"
            exit $status
      fi
      if [ $status != 0 ] ; then
            echo "Failed (exit code $status)... retry $nTrys"
            sleep 15
      fi
   done
}

	
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
retry "pip install nose"

echo "### Installing protobuf using easy_install"
easy_install protobuf	

pushd cosmo-manager

	pushd workflow-service
		echo "### Running bundle install for workflow-service"
		bundle install
	popd
	
	pushd manager-rest
		echo "### Installing manager-rest dependencies"
		retry "pip install . --process-dependency-links"
		if [ $? != 0 ]; then
			exit $?
		fi
	popd

	pushd workflows
		echo "### Installing integration tests dependencies"
		retry "pip install . --process-dependency-links"
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


