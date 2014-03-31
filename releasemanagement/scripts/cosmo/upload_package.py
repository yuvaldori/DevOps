#####################################################
# 	installations for packaging server	          #
#####################################################						
# apt-get update
# make
# python setup-tools python-dev fabric
# ruby2.1
# gem install fpm
# pip
# pip install virtualenv jinja2
# create log dirs:
# sudo mkdir -p /var/log/packager &&
#       sudo touch /var/log/packager/packager.log &&
#####################################################

import sys
import os
import shutil, errno
from fabric.api import * #NOQA
from get import *  # NOQA
from pkg import *  # NOQA
import config
from packager import *  # NOQA
import glob



current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('../..')
print("root dir: "+parent_dir)

def copy_dir(src,dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)



## copy cloudify3 package...
if glob.glob('{0}/cloudify*.deb'.format(config.PACKAGES['cloudify3']['package_path'])):
	print "yes"
	print os.environ["TARZAN_BUILDS"]	
	copy_dir('{0}'.format(config.PACKAGES['cloudify3']['package_path']),os.environ["TARZAN_BUILDS"]+"/3.0.0")
else:
	print "Cannot upload cloudify3 to TARZAN because cloudify deb file is missing"
	sys.exit(1)
	


