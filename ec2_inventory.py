import boto3
import texttable as tt

# This python script for generating EC2 instances inventory

tab = tt.Texttable()
x = [[]]

client = boto3.client('ec2')
response = client.describe_instances()
for r in response['Reservations']:
    for i in r['Instances']:
        status = i['State']['Name']
        instance_id = i['InstanceId']
        ipaddress = i['NetworkInterfaces'][0]['PrivateIpAddress']
        for n in i['Tags']:
            if n[u'Key'] == 'Name':
                name = n[u'Value']
                x.append([name,instance_id,ipaddress,status])

tab.add_rows(x)
tab.set_cols_align(['c','r','r','r'])
tab.header(['Name', 'Instance_id', 'IpAddress', 'Status'])
print tab.draw()
# text = tab.draw()

# f = open('data_new.txt', 'wb')
# f.write(text)
# f.close
