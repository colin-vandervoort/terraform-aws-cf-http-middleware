# # AWS S3 bucket and lambda code zips
# resource "aws_s3_bucket" "lambda_zip_artifacts" {
#   bucket        = var.lambda_zip_bucket_name
#   force_destroy = true
# }

# resource "aws_s3_object" "viewer_req_zip" {
#   bucket = var.lambda_zip_bucket_name
#   key    = lambda_viewer_req_zip_filename
#   source = local.viewer_req_local_zip
#   etag   = filemd5(local.viewer_req_local_zip)
# }

# resource "aws_s3_object" "origin_resp_zip" {
#   bucket = var.lambda_zip_bucket_name
#   key    = lambda_origin_resp_zip_filename
#   source = local.origin_resp_local_zip
#   etag   = filemd5(local.origin_resp_local_zip)
# }

# Allow AWS to execute the middleware Lambda functions in response to events
data "aws_iam_policy_document" "edge_lambda_assume_role" {
  version = "2012-10-17"

  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
    effect = "Allow"
  }
}

# Viewer request event
resource "aws_iam_role" "viewer_req" {
  name               = "viewer_req_iam_role"
  assume_role_policy = data.aws_iam_policy_document.edge_lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.viewer_req.name
  policy_arn = aws_iam_policy.viewer_req_dynamodb.arn
}

resource "aws_lambda_function" "viewer_req" {
  function_name = var.lambda_viewer_req_func_name
  role          = aws_iam_role.viewer_req.arn

  s3_bucket    = var.lambda_zip_bucket_name
  s3_key       = var.lambda_viewer_req_zip_filename
  package_type = "Zip"
  publish      = true

  handler = "index.handler"
  runtime = "nodejs14.x"
}

# # Origin response event
# resource "aws_iam_role" "origin_resp" {
#   name               = "origin_resp_iam_role"
#   assume_role_policy = data.aws_iam_policy_document.edge_lambda_assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
#   role       = aws_iam_role.origin_resp.name
#   policy_arn = aws_iam_policy.origin_resp_dynamodb.arn
# }

# resource "aws_lambda_function" "origin_resp" {
#   function_name = local.origin_resp_func_name
#   role          = aws_iam_role.origin_resp.arn

#   s3_bucket    = var.lambda_zip_bucket_name
#   s3_key       = var.lambda_origin_resp_zip_filename
#   package_type = "Zip"
#   publish      = false

#   handler = "index.handler"
#   runtime = "nodejs14.x"
# }