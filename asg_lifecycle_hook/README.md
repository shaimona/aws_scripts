# AutoScaling Group Lifecycle Hook


You can perform custom actions before an AutoScale group take an action on an instance(ex: terminate).
This is a sample CloudFormation template and lambda function you can use for ssh'ing into an instance and stop apache webserver.


**webserver.yaml:** This is the CloudFormation template that create an AutoScaling group.


**lifecycle_hooks.zip:** Lambda function that SSH in to the server that is being terminated by ASG and stop httpd service

**lifecycle_hooks.py:** Actual python script. This can be edited to change the command you want to run before an instance get terminated.

**Assumptions**

1) You have created a Parameter Store called 'sshkey' with key pair


**Quick Setup**

1) Create a S3 bucket and upload  lifecycle_hooks.zip file
2) Launch CloudFormation Stack using webserver.yaml file

If you customize the python script follow this instruction for creating lambda package [python](https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example-deployment-pkg.html#with-s3-example-deployment-pkg-python).
