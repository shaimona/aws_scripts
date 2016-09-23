#!/bin/bash

# This script will search for unattached ebs volumes in your AWS account and
# delete volumes older than 7 days

# Script require AWS CLI to be installed

# Set retention days
RETENTION_DAYS="7"
# Convert retention days to seconds
RETNTION_IN_SEC=$(date +%s --date "$RETENTION_DAYS days ago")

# Getting list of available volumes
aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[].VolumesId' \
 --output text > /tmp/ebs_available_list

for ebs in `cat /tmp/ebs_available_list`; do
  name=$(aws ec2 describe-volume --volume-ids $ebs --query 'Volumes[].Tags[?key=='Name'].Value' --output text)
  created_time=$(aws ec2 describe-volume --volume-ids $ebs --query 'Volumes[].CreateTime' --output text)
  created_time_in_sec=$(date "--date=$created_time" +%s)
  if (( created_time_in_sec >= RETNTION_IN_SEC )); then
    aws ec2  --volume-id $ebs
    echo "Deleting volume $ebs with name $name"
  fi
done
