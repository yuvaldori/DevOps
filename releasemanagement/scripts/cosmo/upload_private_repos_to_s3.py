import os
import sys
import params
import subprocess
import smtplib

from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from boto.s3.connection import S3Connection
from fabric.api import * #NOQA

#set variables
core_branch_name = os.environ["RELEASE_CORE_BRANCH_NAME"]
plugins_branch_name = os.environ["RELEASE_PLUGINS_BRANCH_NAME"]
AWS_ACCESS_KEY_ID = params.AWS_KEY
AWS_SECRET_KEY = params.AWS_SECRET
DUMMY_AWS_ACCESS_KEY_ID = params.AWS_AUTO_KEY_ID
DUMMY_AWS_SECRET_KEY = params.AWS_AUTO_SECRET_KEY


def send_email(sender,receivers,body):
	msg = MIMEMultipart()
    	msg['From'] = sender
    	msg['To'] = receivers
    	msg['Subject'] = "Signed S3 url"
    	body = body
    	msg.attach(MIMEText(body, 'plain'))
    	message = msg.as_string()
	try:
	   smtpObj = smtplib.SMTP('192.168.10.6')
	   smtpObj.sendmail(sender, receivers, message)
	   print "Successfully sent email"
	except SMTPException:
	   print "Error: unable to send email"

def generate_signed_url():
	bucket = sign_conn.get_bucket(BUCKET_NAME)
	key = bucket.get_key(OBJECT)
	url = key.generate_url(86400)
	return url
	   
def download_private_plugin(repo):
    	tar_file='{0}.tar.gz'.format(repo)
    	os.remove(tar_file) if os.path.exists(tar_file) else None 
    	#ver=os.path.basename(os.path.dirname(k))
    	get_name=subprocess.Popen(['bash', '-c', '. generic_functions.sh ; get_version_name {0} {1} {2}'.format(repo, core_branch_name, plugins_branch_name)],stdout = subprocess.PIPE).communicate()[0] 
    	ver=get_name.rstrip()
    	OBJECT='{0}/{1}/{2}'.format(repo,ver,tar_file)
    	local('curl -u opencm:{0} -L https://github.com/cloudify-cosmo/{1}/archive/{2}.tar.gz > {3}'.format(params.OPENCM_PWD,repo,ver,tar_file),capture=False)
    	bucket = conn.get_bucket(BUCKET_NAME)
    	new_key = bucket.new_key(OBJECT).set_contents_from_filename(tar_file, policy=None)
       	#sign_url=subprocess.Popen(['bash', '-c', '{0}/s3sign_url.sh'.format(scripts_path)],stdout = subprocess.PIPE).communicate()[0]
    	sign_url=generate_signed_url()
    	print sign_url
    	send_email('limor@gigaspaces.com','limor@gigaspaces.com',sign_url)

if __name__ == '__main__':

    if not AWS_ACCESS_KEY_ID or not AWS_SECRET_KEY:
        print '- AWS_ACCESS_KEY_ID / AWS_SECRET_KEY environment variables are not set'
        sys.exit(1)
    conn = S3Connection(AWS_ACCESS_KEY_ID, AWS_SECRET_KEY)
    if not DUMMY_AWS_ACCESS_KEY_ID or not DUMMY_AWS_SECRET_KEY:
        print '- DUMMY_AWS_ACCESS_KEY_ID / DUMMY_AWS_SECRET_KEY environment variables are not set'
        sys.exit(1)
    sign_conn = S3Connection(DUMMY_AWS_ACCESS_KEY_ID, DUMMY_AWS_SECRET_KEY)
    BUCKET_NAME="cloudify-private-repositories"
    
    download_private_plugin('cloudify-vsphere-plugin')
    
  
