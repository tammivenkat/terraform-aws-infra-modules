# -----------------------------
# DB Subnet Group
# -----------------------------
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "my-db-subnet-group"
  }
}

# -----------------------------
# Security Group for DB
# -----------------------------
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL from app layer"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    #cidr_blocks = ["10.0.0.0/16"] # tighten later
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# RDS Instance
# -----------------------------
resource "aws_db_instance" "db" {
  identifier = "my-rds-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = var.db_name
  username = var.username
  password = var.password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "my-rds-db"
  }
}
