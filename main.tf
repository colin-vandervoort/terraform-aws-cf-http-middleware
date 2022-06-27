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

locals {
  origin_resp_func_name          = "cf-middleware-origin-resp"
  dynamodb_url_action_table_name = var.lambda_viewer_req_func_name
}
