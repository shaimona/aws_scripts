#!/usr/bin/env python

''' This script is for identifying S3 buckets with public access
This script is not region specific. This will inspect S3 buckets in all region '''

import boto3

GLOBAL_ALL = "http://acs.amazonaws.com/groups/global/AllUsers"
AUTH_ALL = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"

s3 = boto3.resource('s3')

bucket_names = []

for bucket in s3.buckets.all():
    for grant in s3.BucketAcl(bucket.name).grants:
        if 'URI' in grant['Grantee'] and bucket.name not in bucket_names and grant['Grantee']['URI'] in (GLOBAL_ALL, AUTH_ALL):
            bucket_names.append(bucket.name)
        else:
            continue
print '\n'.join(bucket_names)
