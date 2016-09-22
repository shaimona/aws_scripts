#!/usr/bin/env ruby

# This script is for creating and deleting old ebs snapshots of EC2 instances in AWS
# It is intented to run from a management workstation which has AWS credentials
# This script will search for all the EC2 instances in your account
# take snapshot of each ebs volumes attached to those EC2 instances

# This script assumes that the application/workload is paused/stopped
# on the ec2 instances.
# If the application is running then the snapshot might be useless.

# This script requires AWS cli tool to be installed on your machine.

require 'aws-sdk'

ec2 = Aws::EC2::Client.new(
  region: 'us-west-2'
)

# Get running instances details
instances = ec2.describe_instances(filters:[{name: 'instance-state-name', values:['running']}])
instances.each do |page|
  reservations = page[:reservations]
  reservations.each do |reservation|
    instances = reservation[:instances]
    instances.each do |instance|
      instance_id = instance[:instance_id]
      puts instance_id
      tags = instance[:tags]
      instance_name = nil
      tags.each do |tag|
        if tag[:key] == "Name"
          instance_name = tag[:value]
          puts instance_name
        end
      end
      instance[:block_device_mappings].each do |ebs|
        volume_id = ebs[:ebs][:volume_id]
        puts volume_id
        description = "Snapshot of volume #{volume_id} on server #{instance_name} with instanceId #{instance_id}"
        resp = ec2.create_snapshot({
          description: "#{description}" ,
          volume_id: "#{volume_id}",
        })
        ec2.create_tags({
          resources: [ "#{resp.snapshot_id}",
          ],
          tags: [{
            key: "Name",
            value: "#{instance_name}",
          }]
        })
      end
    end
  end
end
