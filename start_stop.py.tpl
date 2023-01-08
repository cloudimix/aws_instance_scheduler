import boto3
import datetime

now = datetime.datetime.now(datetime.timezone.utc)
current_time = now.strftime("%H:%M:%S")
region = "eu-central-1"
instances = "${workstations_ids}".split(",")
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    status = ec2.describe_instance_status(IncludeAllInstances = True)
    l = []
    for i in status["InstanceStatuses"]:
        l.append(i["InstanceState"]["Name"])
    if 'running' in l:
        ec2.stop_instances(InstanceIds=instances)
        print("Stopped at: ", current_time)
        return 0
    elif 'stopped' in l:
        ec2.start_instances(InstanceIds=instances)
        print("Started at: ", current_time)
        return 0
    else:
        print("Has not scheduled")
        print("current time: ", current_time)
        print(l)
        return 1
