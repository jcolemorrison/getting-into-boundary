resource "random_pet" "database" {
  length = 1
}

resource "random_password" "database" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  special          = true
  override_special = "*!"
}

resource "aws_db_subnet_group" "database" {
  name       = "main"
  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Name = var.project_name
  }
}

resource "aws_db_instance" "database" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "16.4"
  instance_class         = "db.t3.micro"
  db_name                = "catberry"
  identifier             = "${var.project_name}-catberry"
  username               = random_pet.database.id
  password               = random_password.database.result
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-catberry"
  }
}

resource "aws_security_group" "database" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-database"
}

resource "aws_security_group_rule" "database_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.database.id
}

resource "aws_security_group_rule" "database_ingress" {
  security_group_id = aws_security_group.database.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"

  cidr_blocks = [var.vpc_cidr_block, var.hvn_cidr_block]
}