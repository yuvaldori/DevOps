#!/bin/bash -x

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
             echo "Failed (exit code $status)"
             rm -f xunit_reports/xunit-integration-tests.xml
	     scp -rp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i phusion.key root@$IP:/opt/xunit_reports/*.xml xunit_reports
 
	     #sudo docker stop $ID
	     #sudo docker rm $ID
	     exit 1
      fi

}
echo "*** start a new container"

sudo docker run -d cosmo_tests
exit_on_error
echo "*** get container ID"
ID=`sudo docker ps -l | cut -d " " -f1 | tail -n +2 | tr -d ' '`
exit_on_error
echo "container ID="$ID
echo "*** get container IP"
IP=`sudo docker inspect $ID | grep IPAddress | cut -d ":" -f2 | cut -d '"' -f2 | tr -d ' '`
exit_on_error
echo "container IP="$IP
sleep 7

#sudo ssh-keygen -f "/root/.ssh/known_hosts" -R $IP

sudo ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i phusion.key root@$IP 'echo test'
exit_on_error

echo "*** copy nightly folder to the container"
sudo scp -rp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i phusion.key cloudify-* root@$IP:/opt
#exit_on_error
sudo scp -p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i phusion.key * root@$IP:/opt
#exit_on_error
echo "*** run integration tests"
echo "sudo ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i phusion.key root@$IP /opt/cosmo_integration_test.sh"
sudo ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i phusion.key root@$IP "cd /opt ; ./cosmo_integration_test.sh"
exit_on_error
# copy xunit-integration-tests.xml report file from lxc
rm -f xunit_reports/xunit-integration-tests.xml
scp -rp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i phusion.key root@$IP:/opt/xunit_reports/*.xml xunit_reports

#sudo docker stop $ID
#exit_on_error
#sudo docker rm $ID
#exit_on_error
