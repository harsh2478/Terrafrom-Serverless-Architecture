data "archive_file" "python_code"{
  count = length(var.function_names)
  type = "zip"
  source_dir = "${path.module}/python_code/${var.function_names[count.index]}"
  output_path = "${path.module}/python_code/${var.function_names[count.index]}.zip"
}


resource "aws_lambda_function" "my_lambda" {
  count = length(var.function_names)
  filename         = "${path.module}/python_code/${var.function_names[count.index]}.zip"  # Path to your Lambda code package
  function_name    = "${var.function_names[count.index]}"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"  # Using Python runtime
  timeout          = 30
  source_code_hash = data.archive_file.python_code[count.index].output_base64sha256

  environment {
    variables = {
      INSTANCE_IDS = join(",", aws_instance.web[*].id) # Passing instance IDs as comma-separated string
      Cloud_Watch_LogGroup = var.function_names[count.index] == "systemlogs" || var.function_names[count.index] == "webserver_logs" ? join(",", aws_cloudwatch_log_group.log_groups[*].name) : ""
    }
  }
  depends_on = [
	aws_iam_role.lambda_exec_role 
  ]
}





