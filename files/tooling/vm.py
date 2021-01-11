import boto3

ec2 = boto3.client('ec2',
                   'us-west-2',
                   aws_access_key_id='###',
                   aws_secret_access_key='####')

#This function will describe all the instances
#with their current state
#response = ec2.describe_instances()

conn = ec2.run_instances(InstanceType="t2.micro",
                         MaxCount=1,
                         MinCount=1,
                         KeyName='salt_cluster',
                         ImageId="ami-008b09448b998a562")
print(conn)
