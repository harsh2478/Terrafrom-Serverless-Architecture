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
    backup_dir="/path/backup"
    mkdir -p "$backup_dir"
    backup_file="backup_$(date +'%Y-%m-%d').tar.gz"
    backup_files="/etc /var/www /home/user"
    tar -czf "$backup_dir/$backup_file" $backup_files
    if [ $? -eq 0 ]; then
        echo "Backup created successfully: $backup_dir/$backup_file"
    else
        echo "Error: Backup creation failed"
    fi
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
        'body': json.dumps('Backup created successfully')
    }
