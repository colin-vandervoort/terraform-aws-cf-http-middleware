variable "dynamodb_url_action_table_name" {
  type        = string
  description = "Name of the AWS DynamoDB table which will be used for storing actions associated with URLs (e.g. 301 redirects)"
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