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

variable "iam_role_prefix" {
  type        = string
}

variable "lambda_origin_req_func_name" {
  type        = string
  description = "Name for the origin-request Lambda function."
}

variable "lambda_zip_bucket_name" {
  type        = string
  description = "Name of the AWS S3 bucket which will be used for storing zipped Lambda code"
}

variable "lambda_origin_req_zip_filename" {
  type        = string
  description = "Filename of the zipped origin-request code"
}

variable "lambda_origin_resp_zip_filename" {
  type        = string
  description = "Filename of the zipped origin-response code"
}

variable "cf_origin_bucket_name" {
  type = string
}

variable "s3_origin_objects" {
  type = map(object({
    content = string
  }))
}

variable "dynamodb_url_action_table_items" {
  type = map(object({
    target = string
    code   = number
  }))
}

locals {
  s3_origin_id                       = "http_middleware_s3_bucket"
  dynamodb_url_action_table_hash_key = "url"
  dynamodb_url_action_table_name     = var.lambda_origin_req_func_name
}

output "cf_dist_domain" {
  value = aws_cloudfront_distribution.cf_dist.domain_name
}

module "http_middleware" {
  source                          = "../.."
  iam_role_prefix                 = var.iam_role_prefix
  lambda_origin_req_func_name     = var.lambda_origin_req_func_name
  lambda_zip_bucket_name          = var.lambda_zip_bucket_name
  lambda_origin_req_zip_filename  = var.lambda_origin_req_zip_filename
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

resource "aws_s3_bucket" "cf_origin" {
  bucket = var.cf_origin_bucket_name
}

resource "aws_s3_object" "test_pages" {
  for_each = var.s3_origin_objects

  bucket  = aws_s3_bucket.cf_origin.id
  key     = each.key
  content = each.value.content
}

resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  comment = ""
}

resource "aws_cloudfront_distribution" "cf_dist" {
  origin {
    domain_name = aws_s3_bucket.cf_origin.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.http_middleware.lambda_qualified_arn_origin_req
      include_body = false
    }

    # lambda_function_association {
    #   event_type   = "origin-response"
    #   lambda_arn   = module.http_middleware.lambda_qualified_arn_origin_resp
    #   include_body = false
    # }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "test"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}