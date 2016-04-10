#!/bin/bash


clean_bucket()
{
  BUCKET_URL=$1
  THRESHOLD_DATE=$2
  s3cmd ls  -r ${BUCKET_URL}| while read line; do
    FILE_DATE_STRING=`echo $line | awk '{print $1}'`
    FILE_DATE=`date -d $FILE_DATE_STRING '+%s'`
    if (( FILE_DATE < THRESHOLD_DATE )) ; then
          FILE_NAME=`echo $line | grep "com\/gigaspaces\|org\/cloudifysource\|org\/apache\/maven\/plugins\/maven" | grep -v "com\/gigaspaces\/quality\|org\/cloudifysource\/quality" | egrep "[0-9]+\.[0-9]+\.[0-9]+\-[0-9]+\-[0-9]+\-SNAPSHOT" | grep -v "softlayer" | awk '{print $4}'`
        if [ "x$FILE_NAME" != "x" ]; then
          s3cmd del $FILE_NAME
        fi
    fi
  done
}


DATE_7_DAYS_AGO=`date --date="7 days ago" '+%s'`
DATE_45_DAYS_AGO=`date --date="45 days ago" '+%s'`

clean_bucket s3://gigaspaces-maven-repository-eu ${DATE_7_DAYS_AGO}
clean_bucket s3://gigaspaces-repository-eu ${DATE_45_DAYS_AGO}
clean_bucket s3://gigaspaces-repository-eu ${DATE_45_DAYS_AGO}
