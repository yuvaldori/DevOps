import os
import sys
import subprocess
import shutil
import pip

def test():
        print "### Install modules from pypi"
        modules = ['cloudify', 'cloudify-diamond-plugin', 'cloudify-agent-packager']
        for module in modules:
                pip.main(['install', '--pre', '{0}'.format(module)])
        pip freeze
test()
