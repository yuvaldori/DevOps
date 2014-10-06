#REPOS_LIST="blobstore Cloudify-iTests Cloudify-iTests-webuitf gs-ui http-session iTests-Framework mongo-datasource mule openspaces-scala petclinic-jpa rest-data xap xap-cpp xap-jetty xap-ui-web"
REPOS_LIST="blobstore Cloudify-iTests Cloudify-iTests-webuitf gs-ui iTests-Framework mongo-datasource petclinic-jpa rest-data xap xap-jetty xap-ui-web"
echo "REPOS_LIST=$REPOS_LIST"

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		
      fi

}

TAG_NAME="10.1.0_m4_build12585_10_06_2014"

echo "### Repositories list: $REPOS_LIST"

for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"
		
	pushd $r
				
        	git tag -f $TAG_NAME
        	exit_on_error
		git push -f origin tag $TAG_NAME
		exit_on_error
		

  	popd
done
