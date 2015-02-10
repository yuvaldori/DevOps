#!/bin/bash

# 1-hour expiration
ts_exp=$((`date +%s` + 3600))

# string to sign: GET + expiration-time + bucket/object
can_string="GET\n\n\n$ts_exp\n/$bucket/$object"

# generate the signature
sig=$(s3cmd sign "$(echo -e "$can_string")" | sed -n 's/^Signature: //p')

# extract access key from .s3cfg
#s3_access_key=$(sed -n 's/^access_key = //p' ~/.s3cfg)

# sanity check
if [ -z "$s3_access_key" -o -z "$sig" ]; then
    echo "Failed to created signed URL for s3://$bucket/$object" >&2
    exit 1
fi

base_url="https://$bucket.s3.amazonaws.com/$object"
params="AWSAccessKeyId=$s3_access_key&Expires=$ts_exp&Signature=$sig"
echo "$base_url?$params"

