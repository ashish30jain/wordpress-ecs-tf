

module "mysqldb" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "wp_demo"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.large"
  allocated_storage = 100

  name     = "wp_demo"
  username = "wordpress"
  password = var.database_master_password
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  maintenance_window = "Sun:00:00-Sun:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "wordpress-mysql-role"
  create_monitoring_role = true

  tags = {
    Environment = var.env
  }

  # DB subnet group
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "wordpressdb"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name = "character_set_client"
      value = "utf8"
    },
    {
      name = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

resource "aws_ssm_parameter" "secret" {
  name        = "/wpdemo/database/password/master"
  description = "Mysql Password"
  type        = "SecureString"
  value       = var.database_master_password

  tags = {
    environment = var.env
  }