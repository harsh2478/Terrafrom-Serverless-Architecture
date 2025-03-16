resource "aws_api_gateway_rest_api" "my_api" {
  count = length(var.function_names)
  name = "api-${var.function_names[count.index]}"
  description = "My API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  depends_on = [
	aws_lambda_function.my_lambda
  ]
}

resource "aws_api_gateway_resource" "root" {
  count = length(var.function_names)
  rest_api_id = aws_api_gateway_rest_api.my_api[count.index].id
  parent_id = aws_api_gateway_rest_api.my_api[count.index].root_resource_id
  path_part = var.paths[count.index]
  depends_on = [ aws_api_gateway_rest_api.my_api ]
}

resource "aws_api_gateway_method" "proxy" {
  count = length(var.function_names)
  rest_api_id = aws_api_gateway_rest_api.my_api[count.index].id
  resource_id = aws_api_gateway_resource.root[count.index].id
  http_method = "GET"
  authorization = "NONE"
  depends_on = [aws_api_gateway_resource.root]
}

resource "aws_api_gateway_integration" "lambda_integration" {
  count = length(var.function_names)
  rest_api_id = aws_api_gateway_rest_api.my_api[count.index].id
  resource_id = aws_api_gateway_resource.root[count.index].id
  http_method = aws_api_gateway_method.proxy[count.index].http_method
  integration_http_method = "GET"
  type = "AWS_PROXY"
  uri = aws_lambda_function.my_lambda[count.index].invoke_arn
  depends_on = [ 
  	aws_api_gateway_method.proxy, aws_lambda_permission.apigw_lambda_permission
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  count = length(var.function_names)
  depends_on = [
    aws_api_gateway_integration.lambda_integration, aws_lambda_permission.apigw_lambda_permission 
  ]

  rest_api_id = aws_api_gateway_rest_api.my_api[count.index].id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.root[count.index].id,
      aws_api_gateway_method.proxy[count.index].id,
      aws_api_gateway_integration.lambda_integration[count.index].id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  count = length(var.function_names)
  deployment_id = aws_api_gateway_deployment.deployment[count.index].id
  rest_api_id   = aws_api_gateway_rest_api.my_api[count.index].id
  stage_name    = "Dev"
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  count = length(var.function_names)
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda[count.index].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:${aws_api_gateway_rest_api.my_api[count.index].id}/*/${aws_api_gateway_method.proxy[count.index].http_method}/${aws_api_gateway_resource.root[count.index].path_part}"
}
