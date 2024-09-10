resource "random_password" "boundary_db_password" {
  length  = 16
  special = true
}

# Create the PostgreSQL RDS instance
resource "aws_db_instance" "boundary" {
  identifier             = "boundary"
  engine                 = "postgres"
  engine_version         = "16.4"
  instance_class         = "db.t3.micro"
  db_name                = "boundary"
  allocated_storage      = 20
  username               = var.boundary_db_username
  password               = random_password.boundary_db_password.result
  db_subnet_group_name   = aws_db_subnet_group.boundary.name
  vpc_security_group_ids = [aws_security_group.boundary_database.id]
  skip_final_snapshot    = true
  storage_type           = "gp2"

  tags = {
    Name = "boundary-db"
  }
}

# Define the subnet group for the RDS instance
resource "aws_db_subnet_group" "boundary" {
  name       = "boundary-db-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Name = "boundary-db-subnet-group"
  }
}

resource "aws_security_group" "boundary_database" {
  vpc_id = module.vpc.id
  name   = "${var.project_name}-boundary-database"
}

resource "aws_security_group_rule" "allow_boundary_controller_to_db" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.boundary_database.id
  source_security_group_id = aws_security_group.boundary_controller.id
}

resource "aws_security_group_rule" "allow_egress_boundary_db" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.boundary_database.id
}