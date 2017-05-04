#!/usr/bin/env python

# This script is for identifying S3 buckets with public access
import boto3

GLOBAL_ALL = "http://acs.amazonaws.com/groups/global/AllUsers"
AUTH_ALL = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"

s3 = boto3.resource('s3')

for bucket in s3.buckets.all():
    bucket_acl = s3.BucketAcl(bucket.name)
    for grant in bucket_acl.grants:
        if 'URI' in grant['Grantee']:
            if grant['Grantee']['URI'] == GLOBAL_ALL or grant['Grantee']['URI'] == AUTH_ALL:
                print bucket.name
