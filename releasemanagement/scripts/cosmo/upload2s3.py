import sys
import os
import glob
#import params
from boto.s3.connection import S3Connection

#FILES_LIST="*.tar.gz:cludify-centos-agent.tar.gz,*.tar.gz:cludify-ubuntu-agent.tar.gz"
FILES_LIST=os.environ["FILES_LIST"]
#PRODUCT_VERSION="3.2.0"
PRODUCT_VERSION=os.environ["PRODUCT_VERSION"]
#MILESTONE="m6"
MILESTONE=os.environ["MILESTONE"]
#BUILD_NUM="b176"
BUILD_NUM=os.environ["BUILD_NUM"]
#PACKAGE_SOURCE_PATH="/tmp"
PACKAGE_SOURCE_PATH=os.environ["PACKAGE_SOURCE_PATH"]

AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
#AWS_ACCESS_KEY_ID = params.AWS_KEY
#AWS_SECRET_ACCESS_KEY = params.AWS_SECRET

PRODUCT_VERSION_FULL=PRODUCT_VERSION+"-"+MILESTONE+"-"+BUILD_NUM
PACKAGE_DEST_BUILD_DIR=PRODUCT_VERSION+"/"+MILESTONE+"-RELEASE"
PACKAGE_DEST_BUILD_PATH="org/cloudify3/"+PACKAGE_DEST_BUILD_DIR


def upload_file_to_s3(source_file,dest_file):
    #os.chdir( PACKAGE_SOURCE_PATH )
    source_file= glob.glob(os.path.join('{0}'.format(PACKAGE_SOURCE_PATH), source_file))
    source_file = ''.join(source_file)
    full_key_name = os.path.join(PACKAGE_DEST_BUILD_PATH, '{0}_{1}.{2}'.format(dest_file.split(".", 1)[0],PRODUCT_VERSION_FULL,dest_file.split(".", 1)[1]))
    key = bucket.new_key(full_key_name).set_contents_from_filename(source_file, policy='public-read')
    print 'uploaded file {0} to S3 location {1}'.format(source_file,full_key_name)

if __name__ == '__main__':

    BACKET_NAME="gigaspaces-repository-eu"
    if not AWS_ACCESS_KEY_ID or not AWS_SECRET_ACCESS_KEY:
        print '- AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY environment variables are not set'
        sys.exit(1)
    conn = S3Connection(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
    bucket = conn.get_bucket(BACKET_NAME)

    files=[x.strip() for x in FILES_LIST.split(",")]
    for file in files:
        f=file.split(':')
        upload_file_to_s3(f[0],f[1])
