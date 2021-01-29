module "ecs_fargate" {
  source           = "git::https://github.com/tmknom/terraform-aws-ecs-fargate.git?ref=tags/2.0.0"
  name             = local.service_name
  container_name   = local.container_name
  container_port   = local.container_port
  cluster          = aws_ecs_cluster.demo.arn
  subnets          = data.terraform_remote_state.vpc.outptus.private_subnet_ids
  target_group_arn = module.alb.alb_target_group_arn
  vpc_id           = module.vpc.vpc_id

  container_definitions = data.template_file.task_definition.rendered

  desired_count                      = 2
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  deployment_controller_type         = "ECS"
  assign_public_ip                   = false
  health_check_grace_period_seconds  = 10
  platform_version                   = "LATEST"
  source_cidr_blocks                 = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
  cpu                                = 256
  memory                             = local.container_memory
  requires_compatibilities           = ["FARGATE"]
  iam_path                           = "/service_role/"
  description                        = "This is demo"
  enabled                            = true

  create_ecs_task_execution_role = false
  ecs_task_execution_role_arn    = aws_iam_role.default.arn

  tags = {
    Environment = var.workspace
  }
}

data "template_file" "task_definition" {
  template = file("${path.module}/task_definition.json.tpl")

  vars = {
    container_image              = "${var.container_image}:${var.container_version}"
    container_port               = var.container_port
    aws_region                   = var.aws_region
    database_host                = data.terraform_remote_state.rds.outputs.mysql_address
  }
}

resource "aws_iam_role" "default" {
  name               = "ecs-task-execution-for-ecs-fargate"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "default" {
  name   = aws_iam_role.default.name
  policy = data.aws_iam_policy.ecs_task_execution.policy
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_iam_role_policy_attachment" "ssm_default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.policy.arn
}
data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "demo" {
  name = local.cluster_name
}

module "alb" {
  source                     = "git::https://github.com/tmknom/terraform-aws-alb.git?ref=tags/2.1.0"
  name                       = "ecs-fargate"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnet_ids
  access_logs_bucket         = module.s3_lb_log.s3_bucket_id
  enable_https_listener      = true
  enable_http_listener       = false
  enable_deletion_protection = false
  certificates = aws_acm_certificate.cert.arn
}

module "s3_lb_log" {
  source                = "git::https://github.com/tmknom/terraform-aws-s3-lb-log.git?ref=tags/2.0.0"
  name                  = "s3-lb-log-ecs-fargate-${data.aws_caller_identity.current.account_id}"
  logging_target_bucket = module.s3_access_log.s3_bucket_id
  force_destroy         = true
}

module "s3_access_log" {
  source        = "git::https://github.com/tmknom/terraform-aws-s3-access-log.git?ref=tags/2.0.0"
  name          = "s3-access-log-ecs-fargate-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}


data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}
