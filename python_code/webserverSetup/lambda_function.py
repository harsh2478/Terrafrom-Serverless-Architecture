import json
import boto3
import os

def lambda_handler(event, context):
    # Create an SSM client
    ssm_client = boto3.client('ssm')

    # Specify the instance IDs to target with the Run Command
    instance_ids = os.getenv('INSTANCE_IDS', '').split(',')  # Replace with your instance IDs

    # Specify the command to execute
    command = """
    yum install httpd -y
    echo "WELCOME TO YOUR WEB SERVER" > /var/www/html/index.html
    systemctl enable httpd --now
    """

    # Send the Run Command
    response = ssm_client.send_command(
        InstanceIds=instance_ids,
        DocumentName='AWS-RunShellScript',
        Parameters={'commands': [command]},
        TimeoutSeconds=300,
    )

    # Print the command ID for reference
    print("Command ID:", response['Command']['CommandId'])


    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('CONGRATS YOUR WEB SERVER SETUP IS COMPLETE')
    }
