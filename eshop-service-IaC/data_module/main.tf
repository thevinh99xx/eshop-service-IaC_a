
## RDS(Mariadb)  #####################################################
resource "random_string" "password" {
  length  = 10
  special = false
}


resource "aws_db_subnet_group" "service" {
  name        = "eshop-service-terraform-rds-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = [var.subnet_id1, var.subnet_id2]

  tags = {
    Name = "aws db subnet group via terraform"
  }
}


resource "aws_db_instance" "service" {
  identifier             = "eshop-service-keycloackdb"
  allocated_storage      = 10
  engine                 = "mariadb"
  engine_version         = var.mariadb_version
  instance_class         = var.mariadb_instance_class
  db_name                = var.mariadb_name
  username               = var.mariadb_master_user_name
  password               = random_string.password.result
  skip_final_snapshot    = true
  apply_immediately      = true
  vpc_security_group_ids = ["${aws_security_group.mariadb.id}"]
  db_subnet_group_name   = aws_db_subnet_group.service.id
  parameter_group_name   = aws_db_parameter_group.service.name
  ca_cert_identifier     = "rds-ca-rsa2048-g1"
}


resource "aws_db_parameter_group" "service" {
  name   = "eshop-serviceterraparameter"
  family = "mariadb10.5"

  parameter {
    name  = "max_connections"
    value = "1000"
  }
}


resource "aws_security_group" "mariadb" {
  name        = "eshop-service-terraform_rds_sg"
  description = "Terraform RDS MariaDB sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.mariadb_port
    to_port     = var.mariadb_port
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["192.168.0.0/16"]
  # }
}
