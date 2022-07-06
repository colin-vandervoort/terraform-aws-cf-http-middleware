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
  dynamodb_url_action_table_name = var.lambda_origin_req_func_name
}
