resource "aws_iam_policy" "policy" {
  name  = "${var.workspace}-ssm_policy"
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