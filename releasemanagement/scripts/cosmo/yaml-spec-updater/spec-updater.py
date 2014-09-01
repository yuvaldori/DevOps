
"""
Script for uploading spec yaml files to S3 (getcloudify.org).

The script uploads types.yaml from cloudify-manager
and then scans the provided directory for *-plugin directories
and uploads their plugin.yaml file if it exsits.
"""

import os
import sys
import json
import urllib2
import re

import jinja2

from boto.s3.connection import S3Connection
from boto.s3.key import Key


#AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
#AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
AWS_ACCESS_KEY_ID = params.AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY = params.AWS_SECRET_ACCESS_KEY


BUCKET_NAME = 'getcloudify.org'
VERSION_FILE = 'VERSION'
PLUGIN_TEMPLATE_FILE = 'plugin.yaml.template'


def extract_version_number(v):
    pattern = '(\d+\.\d+)'
    m = re.search(pattern, v)
    if m:
        return m.group(1)
    raise ValueError('Unable to extract version number from: {}'.format(v))


def get_version(repo_dir):
    # First try get version from setup.py file
    setup_file = os.path.join(repo_dir, 'setup.py')
    if os.path.exists(setup_file):
        with open(setup_file, 'r') as fs:
            m = re.search("version='(.*)'", fs.read())
            if m:
                return m.group(1)
    raise RuntimeError('Unable to get version from repo: {}'.format(repos_dir))
    # # Try to get the version from
    # dirs = os.walk(repo_dir).next()[1]
    # version_file = None
    # for x in dirs:
    #     version_file = os.path.join(repo_dir, x, VERSION_FILE)
    #     if os.path.exists(version_file):
    #         break
    # if version_file:
    #     with open(version_file, 'r') as f:
    #         return json.loads(f.read())['version']
    # return None


def generate_keys(repos_dir='.'):
    cloudify_types_file = '{}/cloudify-manager/resources/rest-service/'\
                          'cloudify/types/types.yaml'.format(repos_dir)

    if not os.path.exists(cloudify_types_file):
        raise IOError('File not found: {}'.format(cloudify_types_file))

    cloudify_types_version = get_version(os.path.join(
        '{}/cloudify-manager/rest-service'.format(repos_dir)))

    keys = {
        'spec/cloudify/{}/types.yaml'.format(
            extract_version_number(cloudify_types_version)): cloudify_types_file
    }

    dirs = [x for x in os.walk(repos_dir).next()[1] if x.endswith('-plugin')]
    for plugin_dir in dirs:
        plugin_file = os.path.join(repos_dir,
                                   plugin_dir,
                                   PLUGIN_TEMPLATE_FILE)
        if os.path.exists(plugin_file):
            name = str(plugin_dir).replace('cloudify-', '')
            plugin_version = extract_version_number(get_version(os.path.join(repos_dir, plugin_dir)))
            uri = 'spec/{}/{}/plugin.yaml'.format(name, plugin_version)
            keys[uri] = plugin_file
    return keys, cloudify_types_version


def parse_args():
    if len(sys.argv) != 2:
        print '*** Wrong arguments. expected: <repositories_dir>'
        sys.exit(1)
    repos_dir = sys.argv[1]

    if not os.path.exists(repos_dir):
        print '*** Specified repositories directory does not exist: {}'\
            .format(repos_dir)
        sys.exit(1)

    return repos_dir


def get_plugin_yaml_content(cloudify_version, template_file):
    template_dir = os.path.dirname(template_file)
    loader = jinja2.FileSystemLoader(template_dir)
    env = jinja2.Environment(loader=loader)
    template = env.get_template(PLUGIN_TEMPLATE_FILE)
    plugin_branch = get_version(template_dir).replace('a', 'm')
    result = template.render({
        'cloudify_version': cloudify_version,
        'plugin_branch': plugin_branch
    })
    return result


def is_template(yaml_file):
    return yaml_file.endswith('.template')


def get_key_content_as_string(bucket_name, key):
    url = 'http://www.{}/{}'.format(BUCKET_NAME, k)
    return urllib2.urlopen(url).read()


def verify_key_content(url, expected_content):
    actual = urllib2.urlopen(url).read()
    if expected_content != actual:
        raise RuntimeError(
            'Spec: {} does not contain expected content'.format(url))


if __name__ == '__main__':

    print '-- Cloudify spec yaml files S3 updater --'
    repos_dir = parse_args()

    if not AWS_ACCESS_KEY_ID or not AWS_SECRET_ACCESS_KEY:
        print '- AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY environment variables are not set'
        sys.exit(1)

    conn = S3Connection(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

    print '- Getting S3 bucket: {}'.format(BUCKET_NAME)
    bucket = conn.get_bucket(BUCKET_NAME)

    # Display all spec keys
    # keyz = [x.name for x in bucket.get_all_keys(prefix='spec')]
    # print json.dumps(keyz, indent=2)
    # sys.exit(0)

    print '- Generating keys to update... [repos_dir={}]'.format(
        os.path.abspath(repos_dir))

    keys, cloudify_version = generate_keys(repos_dir=repos_dir)

    print '- Cloudify version is: {}'.format(cloudify_version)

    print '- The following keys will be updated:{}{}'.format(
        os.linesep, json.dumps(keys, indent=2))

    updated_urls = []

    for k, v in keys.items():
        print '- Updating key: {}'.format(k)
        key = bucket.get_key(k)
        if key is None:
            print '- Key "{}" does not exist, creating...'.format(k)
            key = Key(bucket)
            key.key = k

        if is_template(v):
            content = get_plugin_yaml_content(cloudify_version, v)
        else:
            with open(v, 'r') as f:
                content = f.read()

        try:
            current_content = get_key_content_as_string(BUCKET_NAME, k)
        except Exception, e:
            current_content = None

        url = 'http://www.{}/{}'.format(BUCKET_NAME, k)

        if current_content == content:
            print '- Content for: {} is already updated - skipping...'.format(k)
        else:
            if key.set_contents_from_string(content) <= 0:
                print '*** Unable to update key: {}'.format(k)
                sys.exit(1)
            updated_urls.append(url)

        print '- Verifying content is available on: {}'.format(url)
        verify_key_content(url, content)

        print '- Key: {} was updated with contents of: {}'.format(k, v)

    print '- Done!'
    print '- Updated URLs:'
    print '- {}'.format(json.dumps(updated_urls))
