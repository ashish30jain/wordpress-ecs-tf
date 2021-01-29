resource "aws_iam_policy" "policy" {
  for_each = data.aws_iam_policy_document.s3_policy
  name  = "${var.workspace}ssmpolicy"
  policy = data.aws_iam_policy_document.ssm_policy.json
}

data "aws_iam_policy_document" "ssm_policy" {
  statement {
    effect = "Allow"      
    actions = [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:GetParameterHistory",
        "ssm:DescribeParameters"      

    ]
    resources =  [
     "arn:aws:ssm:::parameter/wpdemo/database/password/master"
    ]
  }
}