import boto3

ec2 = boto3.client('ec2',
                   'us-west-2',
                   aws_access_key_id='AKIA2MVIN4BVLYXJSLCC',
                   aws_secret_access_key='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')

#This function will describe all the instances
#with their current state
#response = ec2.describe_instances()

conn = ec2.run_instances(InstanceType="t2.micro",
                         MaxCount=1,
                         MinCount=1,
                         KeyName='salt_cluster',
                         ImageId="ami-008b09448b998a562")
print(conn)
