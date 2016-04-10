#!/bin/bash

fileName="params.sh"

#upload docs to website
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "cd /home/tempfiles/bin ; sed -i s/.*MAJOR_OLD=.*/MAJOR_OLD=${MAJOR_OLD}/g $fileName"
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "cd /home/tempfiles/bin ; sed -i s/.*MINOR_OLD=.*/MINOR_OLD=${MINOR_OLD}/g $fileName"
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "cd /home/tempfiles/bin ; sed -i s/.*MAJOR_NEW=.*/MAJOR_NEW=${MAJOR_NEW}/g $fileName"
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "cd /home/tempfiles/bin ; sed -i s/.*MINOR_NEW=.*/MINOR_NEW=${MINOR_NEW}/g $fileName"
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "cd /home/tempfiles/bin ; sed -i s/.*SERVICE_PACK_NEW=.*/SERVICE_PACK_NEW=${SERVICE_PACK_NEW}/g $fileName"
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "cd /home/tempfiles/bin ; sed -i s/.*MILESTONE=.*/MILESTONE=${MILESTONE}/g $fileName"
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "cd /home/tempfiles/bin ; sed -i s/.*BUILD_NUM=.*/BUILD_NUM=${BUILD_NUM}/g $fileName"

ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "cd /home/tempfiles/bin ; ./xap_release.sh"
