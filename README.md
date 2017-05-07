# aws_scripts

This is a repository for scripts I have managing AWS environment

aws_ebs_snapshot.sh: Create EBS snapshot and delete old snapshots.

aws_ebs_snapshot.rb: Create EBS snapshot in Ruby

aws_unused_volume_delete.sh : When you delete an AWS instance any additional ebs volumes
  attached to the instances do not get deleted by default. This script will check
  available volumes and delete them if they are older than 7 days.

ec2_inventory.py: Create EC2 instances inventory


sg_wideopen.py: Find security groups that open from 0.0.0.0 to ports other than 80 and 443

s3_public_bucket: Script that shows all S3 buckets with global grants
