terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "lambda_viewer_req_func_name" {
  type        = string
  description = "Name for the viewer-request Lambda function."
}

variable "lambda_zip_bucket_name" {
  type        = string
  description = "Name of the AWS S3 bucket which will be used for storing zipped Lambda code"
}

variable "lambda_viewer_req_zip_filename" {
  type        = string
  description = "Filename of the zipped viewer-request code"
}

variable "lambda_origin_resp_zip_filename" {
  type        = string
  description = "Filename of the zipped origin-response code"
}

variable "dynamodb_url_action_table_items" {
  type = map(object({
    target = string
    code   = number
  }))
  description = "URL action items to test (e.g. 301 redirects) to test against"
}

locals {
  dynamodb_url_action_table_name = var.lambda_viewer_req_func_name
  dynamodb_url_action_table_hash_key = "url"
}

module "http_middleware" {
  source                          = "../.."
  lambda_viewer_req_func_name     = var.lambda_viewer_req_func_name
  lambda_zip_bucket_name          = var.lambda_zip_bucket_name
  lambda_viewer_req_zip_filename  = var.lambda_viewer_req_zip_filename
  lambda_origin_resp_zip_filename = var.lambda_origin_resp_zip_filename
}

resource "aws_dynamodb_table_item" "test_url_actions" {
  for_each = var.dynamodb_url_action_table_items

  table_name = local.dynamodb_url_action_table_name
  hash_key   = local.dynamodb_url_action_table_hash_key

  item = jsonencode({
    url = {
      S = each.key
    }
    action = {
      M = {
        target = {
          S = each.value.target
        }
        code = {
          N = tostring(each.value.code)
        }
      }
    }
  })

  depends_on = [
    module.http_middleware
  ]
}

data "aws_lambda_invocation" "test_add_trailing_slash" {
  function_name = module.http_middleware.lambda_name_viewer_req

  input = <<JSON
{
  "Records": [
    {
      "cf": {
        "request": {
          "uri": "/foo"
        }
      }
    }
  ]
}
JSON
  depends_on = [
    module.http_middleware
  ]
}

output "test_add_trailing_slash_result" {
  value = jsondecode(data.aws_lambda_invocation.test_add_trailing_slash.result)
}