resource "aws_api_gateway_rest_api" "main" {
  name = "${var.service_name}-${var.stage_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name
}

# Deployment (make sure this is created after all routes)
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    # Force a new deployment on every terraform apply
    redeployment = timestamp()
  }

  depends_on = [
    aws_api_gateway_integration.get_index,
    aws_api_gateway_integration.get_restaurants
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method" "get_index" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_index" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.get_index.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.get_index_lambda.lambda_function_invoke_arn
}

resource "aws_api_gateway_resource" "restaurants" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "restaurants"
}

resource "aws_api_gateway_method" "get_restaurants" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.restaurants.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_restaurants" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.restaurants.id
  http_method = aws_api_gateway_method.get_restaurants.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.get_restaurants_lambda.lambda_function_invoke_arn
}

