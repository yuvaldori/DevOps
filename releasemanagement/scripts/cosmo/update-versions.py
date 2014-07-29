
"""
Bump versions for Cloudify repositories.
Input:
    - Directory containing Cloudify repositories.
    - Cloudify version to bump to.
    - Plugins version to bump to.
    - Build number.
Actions:
    - Update all relevant setup.py files with specified versions.
    - Update 3 VERSION files which are available in runtime.

Versions should be specified in the following format:
    3.1m1
    3.1
    3.1b1
    3.1rc1
"""

__author__ = 'idanmo'


import sys
import os
import argparse
import re
import json

from os import path


PLUGIN_REPO_PATTERN = 'cloudify-.*-[(plugin)|(provider)]'
CLOUDIFY_REPO_PATTERN = 'cloudify-.*'
VERSION_PATTERN = "version=['|\"](.*)['|\"]"


def get_all_setup_files(repos_dir):
    dirs = [
        x for x in os.listdir(repos_dir)
        if path.isdir(
            path.join(repos_dir, x)) and re.search(CLOUDIFY_REPO_PATTERN, x)
    ]
    repos_setup_files = {}
    for repo in dirs:
        setup_files = []
        for root, dirs, files in os.walk(path.join(repos_dir, repo)):
            if 'test' in root:
                continue
            for f in files:
                if f == 'setup.py':
                    setup_files.append(os.path.join(root, f))
        repos_setup_files[repo] = setup_files
    return repos_setup_files


def validate_setup_files(repos_setup_files):
    for repo, setup_files in repos_setup_files.iteritems():
        for x in setup_files:
            with open(x, 'r') as f:
                if not re.search(VERSION_PATTERN, f.read()):
                    raise RuntimeError(
                        "Couldn't find version in: {}".format(x))


def update_setup_file(args, repo, setup_file):
    print '- Updating [{}]: {}'.format(repo, setup_file)
    cloudify_version = '{}{}'.format(args.cloudify_version[0], args.cloudify_version[1]).replace('m', 'a')
    plugins_version = '{}{}'.format(args.plugins_version[0], args.plugins_version[1]).replace('m', 'a')
    with open(setup_file, 'r') as f:
        content = f.read()
        m = re.search(VERSION_PATTERN, content)
        current_version = m.group(0)
        new_version = "version='{}'".format(plugins_version if re.search(PLUGIN_REPO_PATTERN, repo) else cloudify_version)
        content = content.replace(current_version, new_version)
        print '\t- {} -> {}'.format(current_version, new_version)

        matches = re.findall('[\'"](cloudify.*==.*)[\'"]', content)
        for m in matches:
            dep_name = m.split('==')[0]
            new_dep = '{}=={}'.format(dep_name, cloudify_version)
            content = content.replace(m, new_dep)
            print '\t- {} -> {}'.format(m, new_dep)

    with open(setup_file, 'w') as f:
        f.write(content)


def update_setup_files(args):
    print 'Getting all setup.py files...'
    setup_files = get_all_setup_files(args.repositories_dir)

    print 'Found setup.py files: {}'.format(json.dumps(setup_files, indent=2))

    print 'Validating setup.py files...'
    validate_setup_files(setup_files)

    print 'Updating setup.py files...'
    for x in setup_files.keys():
        for f in setup_files[x]:
            update_setup_file(args, x, f)


def update_version_file(args, version_file_relative_path):
    version_file = path.join(args.repositories_dir, version_file_relative_path)
    print '- Updating version file at: {}'.format(version_file)
    if not path.exists(version_file):
        print 'Version file not found at: {}'.format(version_file)
        sys.exit(1)
    version = args.cloudify_version[0]
    if version.count('.') == 1:
        version += '.0'
    if args.cloudify_version[1]:
        version += '-' + args.cloudify_version[1]
    with open(version_file, 'w') as f:
        content = json.dumps(
            {
                'version': version,
                'build': args.build_number,
                'date': '',
                'commit': ''
            },
            indent=2)
        f.write(content)
        print '- Written version file: {}'.format(content)


def _validate_version(version):
    """
    Validates Cloudify and plugins versions.
    Supported format:
    3.0-m1
    3.0.1-m1
    3.1-rc1
    3.1
    3.1-b1
    """
    pattern = '(\d*\.\d)((rc|m|b)\d+)?$'
    m = re.match(pattern, version)
    if not m:
        print 'Illegal version: {}'.format(version)
        sys.exit(1)
    return m.group(1), m.group(2) if m.group(2) else ''


def validate_arguments(args):
    if not path.exists(args.repositories_dir):
        print 'Repositories directory not found: {}'.format(args.repositories_dir)
        sys.exit(1)
    args.cloudify_version = _validate_version(args.cloudify_version)
    args.plugins_version = _validate_version(args.plugins_version)


if __name__ == '__main__':

    print '== Cloudify Version Updater =='

    parser = argparse.ArgumentParser()
    parser.add_argument('--repositories-dir',
                        help='Directory containing Cloudify repositories',
                        required=True)
    parser.add_argument('--cloudify-version',
                        help='Cloudify projects version',
                        required=True)
    parser.add_argument('--plugins-version',
                        help='Cloudify plugins version',
                        required=True)
    parser.add_argument('--build-number',
                        help='Cloudify build number',
                        required=True)

    args = parser.parse_args()

    validate_arguments(args)

    print '- cloudify-version: {}'.format(args.cloudify_version)
    print '- plugins-version: \t{}'.format(args.plugins_version)
    print '- build-number: \t{}'.format(args.build_number)

    update_setup_files(args)

    update_version_file(args, 'cosmo-ui/VERSION')
    update_version_file(args, 'cloudify-cli/cosmo_cli/VERSION')
    update_version_file(args, 'cloudify-manager/rest-service/manager_rest/VERSION')

    print 'Done!'
