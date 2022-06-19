output "lambda_name_viewer_req" {
  value = local.viewer_req_func_name
}

output "lambda_qualified_arn_viewer_req" {
  value = aws_lambda_function.viewer_req.qualified_arn
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
