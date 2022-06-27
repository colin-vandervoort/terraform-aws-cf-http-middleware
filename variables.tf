variable "lambda_viewer_req_func_name" {
  type        = string
  description = "Name for the viewer-request Lambda function. This name will be reused for the url actions table name, so it must be unique."
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