from ensurepip import bootstrap
import boto3

client = boto3.client('ec2', region_name='us-east-1')
Myec2 = client.describe_instances()
for pythonins in Myec2['Reservations']:
    for instance in pythonins['Instances']:
        if instance['State']['Name'] == 'running':
            print(instance['InstanceId'])
            ec2 = boto3.resource('ec2')
            instance = ec2.Instance(instance['InstanceId'])
            print(instance.public_dns_name)