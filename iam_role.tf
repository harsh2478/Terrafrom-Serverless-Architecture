resource "aws_iam_role" "ssm_access" {
  name = "SSMFullAccess"

# It defines which service or user or group used this role, here ec2 instance going to use this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "attachment" {
  name       = "my-ssm-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"  # Replace with your policy ARN
  roles       = [aws_iam_role.ssm_access.name] # Reference the IAM role created above
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "EachLambdaRole"

# It defines which service or user or group used this role, here ec2 instance going to use this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_policy_attachment" "lambdaRole-adminAccess" {
  name       = "lambdaRoleAdminAccess-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  # Replace with your policy ARN
  roles       = [aws_iam_role.lambda_exec_role.name] # Reference the IAM role created above
}

resource "aws_iam_policy_attachment" "lambdaRole-LambdaBasicExecution" {
  name       = "lambdaRoleBasic-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"  # Replace with your policy ARN
  roles       = [aws_iam_role.lambda_exec_role.name] # Reference the IAM role created above
}

