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
# from get import *  # NOQA
# from pkg import *  # NOQA
import packages
from packman.packman import *  # NOQA

#os.environ["PACK_COMPONENTS"]="yes"
#os.environ["PACK_CORE"]="yes"
#os.environ["PACK_UI"]="yes"
#os.environ["BUILD_NUM"]="1-248"
#os.environ["PRODUCT_VERSION_FULL"]="3.0.0-m1-b1-248"

PACK_COMPONENTS=os.environ["PACK_COMPONENTS"]
PACK_CORE=os.environ["PACK_CORE"]
PACK_UI=os.environ["PACK_UI"]
BUILD_NUM=os.environ["BUILD_NUM"]
PRODUCT_VERSION=os.environ["PRODUCT_VERSION_FULL"]

print PACK_COMPONENTS
print PACK_CORE
print PACK_UI
print BUILD_NUM
print PRODUCT_VERSION

def copy_dir(src,dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('..')
print("root dir: "+parent_dir)


manager_conf = packages.PACKAGES['manager']
celery_conf = packages.PACKAGES['celery']
cloudify_ui_conf = packages.PACKAGES['cloudify-ui']
#cloudify_ubuntu_agent_conf = packages.PACKAGES['cloudify-ubuntu-agent']
#ubuntu_agent_conf = packages.PACKAGES['Ubuntu-agent']
cloudify_core_conf = packages.PACKAGES['cloudify-core']


PACKAGE_SOURCE_PATH='{0}'.format(cloudify_core_conf['package_path'])
'''if os.path.exists(PACKAGE_SOURCE_PATH):
	#local('sudo chown tgrid -R {0}'.format(PACKAGE_SOURCE_PATH),capture=False)
	shutil.rmtree(PACKAGE_SOURCE_PATH)'''


p = PythonHandler()

if PACK_CORE == "yes":


	print("*** packaging manager")
	if os.path.exists(manager_conf['package_path']):
		shutil.rmtree(manager_conf['package_path'])

	## prepares virtualenv and copies relevant files to manager virtualenv
	do('pkm get -c manager')
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-amqp-influxdb'), manager_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	## install dsl-parser with dependencies into manager virtualenv (installing before manager-rest so manager-rest will not install it as dependency)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-dsl-parser'), manager_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	## install manager with dependencies into manager virtualenv
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-manager/rest-service'), manager_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	do('pkm pack -c manager')
	##rename manager package
	manager_file = glob.glob(os.path.join('{0}'.format(manager_conf['package_path']), '{0}*.deb'.format(manager_conf['name'])))
	manager_file = ''.join(manager_file)
	print manager_file
	os.rename(str(manager_file),'{0}/{1}'.format(manager_conf['package_path'],'manager_'+PRODUCT_VERSION+'_amd64.deb'))

	print("*** packaging celery")
	if os.path.exists(celery_conf['package_path']):
		shutil.rmtree(celery_conf['package_path'])
	do('pkm get -c celery')
	## install celery with dependencies into celery virtualenv
	r=p.pip('celery==3.1.17', celery_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-rest-client'), celery_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-plugins-common'), celery_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-manager/plugins/plugin-installer'), celery_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-manager/plugins/agent-installer'), celery_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-manager/plugins/riemann-controller'), celery_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-manager/workflows'), celery_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	do('pkm pack -c celery')
	celery_file = glob.glob(os.path.join('{0}'.format(celery_conf['package_path']), '{0}*.deb'.format(celery_conf['name'])))
	celery_file = ''.join(celery_file)
	print celery_file
	##rename celery package
	os.rename(celery_file,'{0}/{1}'.format(celery_conf['package_path'],'celery_'+PRODUCT_VERSION+'_amd64.deb'))

	print("*** packaging cloudify-core")
	if  manager_file and celery_file:
		do('pkm pack -c cloudify-core')
		cloudify_core_file = glob.glob(os.path.join('{0}'.format(cloudify_core_conf['package_path']), '{0}*.deb'.format(cloudify_core_conf['name'])))
		cloudify_core_file = ''.join(cloudify_core_file)
		print cloudify_core_file
		##rename cloudify-core package
		os.rename(cloudify_core_file,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,'cloudify-core_'+PRODUCT_VERSION+'_amd64.deb'))
	else:
		print "Cannot pack cloudify-core because missing deb files"
		sys.exit(1)


	'''print("*** packaging ubuntu-agent")
	print(ubuntu_agent_conf['package_path'])
	if os.path.exists(ubuntu_agent_conf['package_path']):
		shutil.rmtree(ubuntu_agent_conf['package_path'])
	do('pkm get -c Ubuntu-agent')
	## install linux_agent with dependencies into celery virtualenv
	r=p.pip('celery==3.0.24', ubuntu_agent_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('pyzmq==14.3.1', ubuntu_agent_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-rest-client'), ubuntu_agent_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-plugins-common'), ubuntu_agent_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-script-plugin'), ubuntu_agent_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-manager/plugins/plugin-installer'), ubuntu_agent_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	r=p.pip('{0}/'.format(parent_dir + '/cloudify-manager/plugins/agent-installer'), ubuntu_agent_conf['sources_path'])
	if r.return_code != 0:
		exit(1)
	##create tar file
	do('pkm pack -c Ubuntu-agent')
	##create deb file
	do('pkm pack -c cloudify-ubuntu-agent')
	ubuntu_agent_file = glob.glob(os.path.join('{0}'.format(PACKAGE_SOURCE_PATH),'{0}*amd64.deb'.format(cloudify_ubuntu_agent_conf['name'])))
	ubuntu_agent_file = ''.join(ubuntu_agent_file)
	print "PACKAGE_SOURCE_PATH="+PACKAGE_SOURCE_PATH
	print "ubuntu_agent_file="+ubuntu_agent_file

	ubuntu_agent_file32 = glob.glob(os.path.join('{0}'.format(PACKAGE_SOURCE_PATH),'{0}*x86_64.rpm'.format(cloudify_ubuntu_agent_conf['name'])))
	ubuntu_agent_file32 = ''.join(ubuntu_agent_file32)
	print "ubuntu_agent_file32="+ubuntu_agent_file32

	##rename ubuntu-agent package
	os.rename(ubuntu_agent_file,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,'cloudify-ubuntu-agent_'+PRODUCT_VERSION+'_amd64.deb'))
	os.rename(ubuntu_agent_file32,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,'cloudify-ubuntu-agent_'+PRODUCT_VERSION+'_x86_64.rpm'))
	'''
print("*** packaging winsows-agent")
do('pkm pack -c cloudify-windows-agent')

if PACK_UI == "yes":

	print("*** packaging ui")
	do('pkm get -c cloudify-ui')
	#shutil.copyfile(parent_dir+"/cosmo-ui/dist/cosmo-ui-1.0.0.tgz", "{0}/cosmo-ui-1.0.0.tgz".format(cloudify_ui_conf['sources_path']))
	#pkg_cloudify_ui()

	tar_ui_file = glob.glob(os.path.join(parent_dir+'/cloudify-ui/dist','cosmo-ui*.tgz'))
	print tar_ui_file
	shutil.copy(''.join(tar_ui_file),'{0}'.format(cloudify_ui_conf['sources_path']))
	tar_ui_grafana_file = glob.glob(os.path.join(parent_dir+'/cosmo-grafana/dist','grafana*.tgz'))
	print tar_ui_grafana_file
	shutil.copy(''.join(tar_ui_grafana_file),'{0}'.format(cloudify_ui_conf['sources_path']))

	if  tar_ui_file:
		do('pkm pack -c cloudify-ui')
		cloudify_ui_file = glob.glob(os.path.join('{0}'.format(cloudify_ui_conf['package_path']), '{0}*.deb'.format(cloudify_ui_conf['name'])))
		cloudify_ui_file = ''.join(cloudify_ui_file)
		print cloudify_ui_file
		##rename cloudify-ui package
		os.rename(cloudify_ui_file,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,'cloudify-ui_'+PRODUCT_VERSION+'_amd64.deb'))

	else:
		print "Cannot pack cloudify-ui because missing tar files"
		sys.exit(1)







local('sudo chown tgrid -R /opt',capture=False)
