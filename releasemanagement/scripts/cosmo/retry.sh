function retry 
{
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