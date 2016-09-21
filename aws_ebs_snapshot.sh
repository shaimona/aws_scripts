#!/bin/bash

# This script is for creating and deleting old ebs snapshots of EC2 instances in AWS
# It is intented to run from a management workstation which has AWS credentials
# This script will search for all the EC2 instances in your account
# take snapshot of each ebs volumes attached to those EC2 instances

# This script assumes that the application/workload is paused/stopped
# on the ec2 instances.
# If the application is running then the snapshot might be useless.

# This script requires AWS cli tool to be installed on your machine.

# Set Today's date
TODAY=`date +%F`
# Set retention days
RETENTION_DAYS="7"
# Convert retention days to seconds
RENTION_IN_SEC=$(date +%s --date "$RETENTION_DAYS days ago")

# Get list of running instances
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId' --output text > /tmp/ec2list

for instance in `cat /tmp/ec2list`; do
  # Getting list of attached volumes
  aws ec2 describe-instances --instance-ids $instance --query Reservations[].Instances[].BlockDeviceMappings[].Ebs[].VolumeId --output text > /tmp/volumeid
  instance_name=$(aws ec2 describe-instances --instance-ids $instance --query Reservations[].Instances[].Tags[?key=='Name'].Value[] --output text)
  for ebs in `cat /tmp/volumeid`; do
    # Creating snapshots
    snap_description="Snapshot of volume $ebs from Instance $instance_name, InstanceId $instance on $TODAY"
    snap_id=$(aws ec2 create-snapshot --volume-id $ebs --description "$snap_description" --query SnapshotId --output text)
    aws ec2 create-tags --resource $snap_id --tags Key=Name,Value=$instance_name Key=CreatedBy,Value=AutomatedBackup
  done
done

# Delete snapshots older than retention date
for volume in `cat /tmp/volumeid`; do
  # Getting snapshot list
  snapshot_list=$(aws ec2 describe-snapshots --filters "Name=volume-id,Values=$volume" \
  "Name=tag:CreatedBy,Values=Automatedbackup" --query Snapshots[].SnapshotId --output text)
  for snapshot in $snapshot_list; do
    # Comparing snapshot creation date
    snapshot_date=$(aws ec2 describe-snapshots --output=text --snapshot-ids \
    $snapshot --query Snapshots[].StartTime | awk -F "T" '{printf "%s\n", $1}')
    snapshot_date_in_sec=$(date "--date=$snapshot_date" +%s)
    # Deleting snapshots older than retention days.
    if (( $snapshot_date_in_sec <= $RENTION_IN_SEC )); then
      aws ec2 delete-snapshot --snapshot-id $snapshot
    fi
  done
done
