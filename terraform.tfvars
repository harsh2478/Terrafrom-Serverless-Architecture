bucket_name = "server-management"
instancetype = "t2.micro"
ec2_names = ["Webserver-SystemBackUp"]
function_names = ["backup_system", "systemlogs", "webserverSetup", "webserver_logs"]
cloudwatch_log_groups = ["systemlogs", "webserver_logs"]
aws_azs = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["192.168.1.0/24", "192.168.2.0/24"]
private_subnet_cidrs = ["192.168.3.0/24", "192.168.4.0/24"]
paths = ["backup", "log", "serversetup", "weblogs"]
