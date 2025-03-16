import json
import boto3
import os


def lambda_handler(event, context):
    # Create an SSM client
    ssm_client = boto3.client('ssm')

    # Specify the instance IDs to target with the Run Command
    instance_ids = os.getenv('INSTANCE_IDS', '').split(',')  # Replace with your instance IDs
    cloudwatch_log_groups = os.getenv('Cloud_Watch_LogGroup', '').split(',')

    # Specify the command to execute
    command = """
    uptime && echo " " && free -h && echo " " && df -h
    """

    # Send the Run Command
    response = ssm_client.send_command(
        InstanceIds=instance_ids,
        DocumentName='AWS-RunShellScript',
        Parameters={'commands': [command]},
        CloudWatchOutputConfig={
            'CloudWatchLogGroupName': cloudwatch_log_groups[0],
            'CloudWatchOutputEnabled': True
        },
        TimeoutSeconds=300,
    )

    # Print the command ID for reference
    print("Command ID:", response['Command']['CommandId'])

    logs_client = boto3.client('logs',
                           region_name='us-east-1')

    log_group_name = cloudwatch_log_groups[0]

    response = logs_client.describe_log_streams(logGroupName=log_group_name, orderBy='LastEventTime', descending=True, limit=2)
    log_streams = response['logStreams']
    if not log_streams:
        print("No log streams found in the log group:", log_group_name)
        exit(1)

    log_stream_names = [log_stream['logStreamName'] for log_stream in log_streams]
    output = []
    # Retrieve and print logs from each log stream
    for log_stream_name in log_stream_names:
        response = logs_client.get_log_events(logGroupName=log_group_name, logStreamName=log_stream_name, limit=2)
        events = response['events']
        if events:
            print("Log Stream:", log_stream_name)
            for event in events:
                output.append(event['message'])
                print(event['message'])

    # TODO implement
    final = []
    for n in [0,1]:
        answer = output[n]
        formatted_output = answer.split("\n")
        final.append(formatted_output)

    return final
