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

fail_file=cosmo_unit_tests_fail.log


#REPOS_LIST="cosmo-plugin-agent-installer,cosmo-celery-common,cosmo-manager,cosmo-cli,cosmo-plugin-plugin-installer,\
#cosmo-plugin-openstack-provisioner,cosmo-plugin-python-webserver,cosmo-manager-rest-client,cosmo-plugin-kv-store,\
#cosmo-fabric-runner,cosmo-plugin-vagrant-provisioner"

# Order is important!
#REPOS_LIST="cosmo-fabric-runner,cosmo-manager-rest-client,cosmo-celery-common,cosmo-plugin-plugin-installer,cosmo-plugin-kv-store,cosmo-manager,cosmo-cli"

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
	
	if [ "$r" = "cosmo-manager" ]
	then		
		r="$r/manager-rest"
	fi

	pushd $r

	echo "### Installing [$r] dependencies"
	if [ "$r" = "cosmo-celery-common" ]
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
	if [ "$r" = "cosmo-fabric-runner" ]
	then
		retry "pip install -r test-requirements.txt"
		nosetests cosmo_fabric/tests/test_fabric_retry_runner.py:TestLocalRunnerCase -e .*sudo.*
	elif [ "$r" = "cosmo-plugin-agent-installer" ]
	then
		nosetests worker_installer/tests/test_worker_installer.py:TestLocalInstallerCase --nologcapture --nocapture
	else
		nosetests . --nologcapture --nocapture
	fi

	result=`echo $?`
	echo "### Nosetests exited with code $result"
        if [ $result -ne 0 ]; then
		cosmo_unit_tests_fail="$r,$cosmo_unit_tests_fail"			
   		echo "### Unit tests failed for: $r";   			
	fi
	
	popd
	
	cat </dev/null>$fail_file
	echo "### cosmo_unit_tests_fail=$cosmo_unit_tests_fail"
	echo "$cosmo_unit_tests_fail" > $fail_file 
  	
done

deactivate
