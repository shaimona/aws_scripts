#!/bin/env python
''' This script is for identifying AWS security groups that has wide open
access(0.0.0.0) to ports other than 80 and 443. Also identify security groups
that has all the ports open'''

import boto3

client = boto3.client('ec2')
response = client.describe_security_groups()

for s in response['SecurityGroups']:
    for i in s['IpPermissions']:
        if i.has_key('FromPort'):
            fromport = i['FromPort']
            for r in i['IpRanges']:
                if (fromport != 80 and fromport != 443) and r['CidrIp'] == '0.0.0.0/0':
                    print s['GroupName']
        if i.has_key('IpProtocol') and i['IpProtocol'] == '-1':
            for r in i['IpRanges']:
                if r['CidrIp'] == '0.0.0.0/0':
                    print s['GroupName']
