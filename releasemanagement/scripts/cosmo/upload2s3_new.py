import commands
import sys
import os
import shutil, errno
from fabric.api import * #NOQA
import glob
import params
from boto.s3.connection import S3Connection

FILES_LIST="*.tar.gz:cludify-centos-agent.tar.gz"
PRODUCT_VERSION="3.2.0"
MILESTONE="m6"
BUILD_NUM="b176"
PACKAGE_SOURCE_PATH="/tmp"
#3.1.0-ga-b85
PRODUCT_VERSION_FULL=PRODUCT_VERSION+"-"+MILESTONE+"-"+BUILD_NUM
PACKAGE_DEST_BUILD_DIR=PRODUCT_VERSION+"/"+MILESTONE+"-RELEASE"
PACKAGE_DEST_BUILD_PATH="org/cloudify3/"+PACKAGE_DEST_BUILD_DIR


def upload_file_to_s3(source_file,dest_file):
    os.chdir( PACKAGE_SOURCE_PATH )
    full_key_name = os.path.join(PACKAGE_DEST_BUILD_PATH, source_file)
    key = bucket.new_key(full_key_name).set_contents_from_filename(dest_file, policy='public-read')
    print "uploaded file %s to S3" % fname

if __name__ == '__main__':
    
    BACKET_NAME="gigaspaces-repository-eu"
    bucket = conn.get_bucket(BACKET_NAME)
    conn = S3Connection(aws_access_key_id=params.AWS_KEY, aws_secret_access_key=params.AWS_SECRET)
    
    files=[x.strip() for x in FILES_LIST.split(",")]
    for file in files:
        f=file.split(':')
            upload_file_list_to_s3(f[0],f[1])


