
import boto3
import paramiko


def handler(event, context):
    print event
    instance = event['detail']['EC2InstanceId']
    client = boto3.client('ec2')
    response = client.describe_instances(
      Filters=[{'Name': 'instance-id',
                'Values': [instance]}]
    )

    # Get IP address of the instance
    for r in response['Reservations']:
        for i in r['Instances']:
            private_ip = i['PrivateIpAddress']

    # Getting ssh key from parameter store
    ssm = boto3.client('ssm')
    keys = ssm.get_parameters(
        Names=['sshkey']
    )
    for key in keys['Parameters']:
        ssh_key = key['Value']

    f = open('/tmp/keyname.pem', 'w')
    f.write(ssh_key)
    f.close()

    # SSH into the instance and run command
    k = paramiko.RSAKey.from_private_key_file("/tmp/keyname.pem")
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    print 'Connecting to ' + private_ip
    c.connect(hostname=private_ip, username="ec2-user", pkey=k)

    commands = [
        '/sbin/service httpd stop'
    ]

    for command in commands:
        stdin, stdout, stderr = c.exec_command(command)
        print stdout.read()
        print stderr.read()

    return {
        'message': "Execution completed"
    }
