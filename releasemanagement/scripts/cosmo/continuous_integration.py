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
import glob
import shutil, errno
from fabric.api import * #NOQA
from get import *  # NOQA
from pkg import *  # NOQA
import config
from packager import *  # NOQA


print("*** packaging manager")
# prepares virtualenv and copies relevant files to manager virtualenv
get_manager()
# copy manager and dsl-parser repos to manager venv
current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('../..')
print("root dir: "+parent_dir)

def copy_dir(src,dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

## install dsl-parser with dependencies into manager virtualenv (installing before manager-rest so manager-rest will not install it as dependency)
do('{0}/bin/pip --default-timeout=45 install {1}'.format(config.PACKAGES['manager']['sources_path'],parent_dir+'/cosmo-plugin-dsl-parser'))

## install manager with dependencies into manager virtualenv
do('{0}/bin/pip --default-timeout=45 install {1}'.format(config.PACKAGES['manager']['sources_path'],parent_dir+'/cosmo-manager/manager-rest'))

## package manager virtualenv
pkg_manager()

print("*** packaging celery")
get_celery()
## install celery with dependencies into celery virtualenv
do('{0}/bin/pip --default-timeout=45 install {1}'.format(config.PACKAGES['celery']['sources_path'],parent_dir+'/cosmo-fabric-runner'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(config.PACKAGES['celery']['sources_path'],parent_dir+'/cosmo-manager-rest-client'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(config.PACKAGES['celery']['sources_path'],parent_dir+'/cosmo-celery-common'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(config.PACKAGES['celery']['sources_path'],parent_dir+'/cosmo-plugin-kv-store'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(config.PACKAGES['celery']['sources_path'],parent_dir+'/cosmo-plugin-plugin-installer'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(config.PACKAGES['celery']['sources_path'],parent_dir+'/cosmo-plugin-agent-installer'))
pkg_celery()

print("*** packaging ui")
shutil.copyfile(parent_dir+"/cosmo-ui/dist/cosmo-ui-1.0.0.tgz", "{0}/cosmo-ui-1.0.0.tgz".format(config.PACKAGES['cosmo-ui']['sources_path']))
get_cosmo_ui()
pkg_cosmo_ui()

manager_file = glob.glob(os.path.join('{0}'.format(config.PACKAGES['manager']['package_path']), '{0}*.deb'.format(config.PACKAGES['manager']['name'])))
print manager_file
celery_file = glob.glob(os.path.join('{0}'.format(config.PACKAGES['celery']['package_path']), '{0}*.deb'.format(config.PACKAGES['celery']['name'])))
print celery_file
ui_file = glob.glob(os.path.join('{0}'.format(config.PACKAGES['cosmo-ui']['package_path']), '{0}*.deb'.format(config.PACKAGES['cosmo-ui']['name'])))
print ui_file
if  manager_file and celery_file and ui_file:
	pkg_cloudify3()
else:
	print "Cannot pack cloudify3 because missing deb files"
	sys.exit(1)

## copy cloudify3 package...
#if glob.glob('{0}/cloudify*.deb'.format(config.PACKAGES['cloudify3']['package_path'])):
#	print "yes"
#	print os.environ["TARZAN_BUILDS"]	
#	copy_dir('{0}'.format(config.PACKAGES['cloudify3']['package_path']),os.environ["TARZAN_BUILDS"]+"/3.0.0")


