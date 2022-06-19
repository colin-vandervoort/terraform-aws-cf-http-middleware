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
  # viewer_req_local_zip = "middleware/viewer-req/${var.lambda_viewer_req_zip_filename}"
  viewer_req_func_name = "cf-middleware-viewer-req"

  # origin_resp_local_zip = "middleware/origin-resp/${var.lambda_origin_resp_zip_filename}"
  origin_resp_func_name = "cf-middleware-origin-resp"
}
