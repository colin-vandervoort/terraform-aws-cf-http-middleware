output "lambda_name_origin_req" {
  value = var.lambda_origin_req_func_name
}

output "dynamodb_url_action_table_name" {
  value = local.dynamodb_url_action_table_name
}

output "lambda_qualified_arn_origin_req" {
  value = aws_lambda_function.origin_req.qualified_arn
}

# output lambda_qualified_arn_origin_resp {
#   value       = aws_lambda_function.origin_resp.arn
# }

# output "lambda_name_origin_resp" {
#   value = local.origin_resp_func_name
# }

# output "lambda_zip_bucket_arn" {
#   value = aws_s3_bucket.lambda_zip_artifacts.arn
# }

# output "middleware_admin_iam_user_arn" {
#   value = aws_iam_user.middleware_admin.arn
# }
