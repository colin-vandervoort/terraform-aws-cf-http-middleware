resource "aws_dynamodb_table" "url_actions" {
  name           = local.dynamodb_url_action_table_name
  billing_mode   = "PAY_PER_REQUEST"
  table_class    = "STANDARD"
  stream_enabled = false
  hash_key       = "url"

  attribute {
    name = "url"
    type = "S"
  }
}

data "aws_iam_policy_document" "viewer_req_dynamodb" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    resources = [
      "${aws_dynamodb_table.url_actions.arn}",
      "${aws_dynamodb_table.url_actions.arn}/index"
    ]
    actions = [
      "dynamodb:GetItem",
    ]
  }
}


resource "aws_iam_policy" "viewer_req_dynamodb" {
  name   = "${var.iam_role_prefix}-access-dynamodb-from-viewer-req-lambda"
  policy = data.aws_iam_policy_document.viewer_req_dynamodb.json
}


# data "aws_iam_policy_document" "url_action_table_manage" {
#   version = "2012-10-17"
#   statement {
#     resources = [
#       "${aws_dynamodb_table.url_actions.arn}",
#       "${aws_dynamodb_table.url_actions.arn}/index"
#     ]
#     actions = [
#       "dynamodb:PutItem",
#       "dynamodb:UpdateItem",
#       "dynamodb:DeleteItem",
#       "dynamodb:BatchWriteItem",
#       "dynamodb:GetItem",
#       "dynamodb:BatchGetItem",
#       "dynamodb:Scan",
#       "dynamodb:Query",
#       "dynamodb:ConditionCheckItem"
#     ]
#   }
# }

# resource "aws_iam_user" "middleware_admin" {
#   name = "middleware-admin"
# }

# resource "aws_iam_access_key" "middleware_admin" {
#   user = aws_iam_user.middleware_admin.name
# }

# resource "aws_iam_user_policy_attachment" "test-attach" {
#   user       = aws_iam_user.middleware_admin.name
#   policy_arn = data.aws_iam_policy_document.url_action_table_manage.json
# }