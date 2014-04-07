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
import packages
from packman import *  # NOQA

def copy_dir(src,dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('../..')
print("root dir: "+parent_dir)


print("*** packaging manager")
# prepares virtualenv and copies relevant files to manager virtualenv
get_manager()
## install dsl-parser with dependencies into manager virtualenv (installing before manager-rest so manager-rest will not install it as dependency)
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['manager']['sources_path'],parent_dir+'/cloudify-dsl-parser'))
## install manager with dependencies into manager virtualenv
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['manager']['sources_path'],parent_dir+'/cloudify-manager/rest-service'))

## package manager virtualenv
pkg_manager()

print("*** packaging celery")
get_celery()
## install celery with dependencies into celery virtualenv
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['celery']['sources_path'],parent_dir+'/cloudify-rest-client'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['celery']['sources_path'],parent_dir+'/cloudify-plugins-common'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['celery']['sources_path'],parent_dir+'/cloudify-manager/plugins/plugin-installer'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['celery']['sources_path'],parent_dir+'/cloudify-manager/plugins/agent-installer'))
pkg_celery()

print("*** packaging ui")
get_cosmo_ui()
shutil.copyfile(parent_dir+"/cosmo-ui/dist/cosmo-ui-1.0.0.tgz", "{0}/cosmo-ui-1.0.0.tgz".format(packages.PACKAGES['cosmo-ui']['sources_path']))
pkg_cosmo_ui()

manager_file = glob.glob(os.path.join('{0}'.format(packages.PACKAGES['manager']['package_path']), '{0}*.deb'.format(packages.PACKAGES['manager']['name'])))
print manager_file
celery_file = glob.glob(os.path.join('{0}'.format(packages.PACKAGES['celery']['package_path']), '{0}*.deb'.format(packages.PACKAGES['celery']['name'])))
print celery_file
ui_file = glob.glob(os.path.join('{0}'.format(packages.PACKAGES['cosmo-ui']['package_path']), '{0}*.deb'.format(packages.PACKAGES['cosmo-ui']['name'])))
print ui_file
if  manager_file and celery_file and ui_file:
	pkg_cloudify3()
else:
	print "Cannot pack cloudify3 because missing deb files"
	sys.exit(1)


print("*** packaging linux-agent")

get_linux_agent()
## install linux_agent with dependencies into celery virtualenv
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['linux-agent']['sources_path'],parent_dir+'/cloudify-rest-client'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['linux-agent']['sources_path'],parent_dir+'/cloudify-plugins-common'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['linux-agent']['sources_path'],parent_dir+'/cloudify-manager/plugins/plugin-installer'))
do('{0}/bin/pip --default-timeout=45 install {1}'.format(packages.PACKAGES['linux-agent']['sources_path'],parent_dir+'/cloudify-manager/plugins/agent-installer'))
pkg_linux_agent()
pkg_ubuntu_agent()




