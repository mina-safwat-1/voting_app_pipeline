# Create DB subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "postgres-subnet-group"
  subnet_ids = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "private"
  ]

  tags = {
    Name = "Postgres Subnet Group"
  }
}

# Create security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "postgres-security-group"
  description = "Allow access to PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow PostgreSQL access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # Restrict to VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres-security-group"
  }
}

# Create RDS instance (Free Tier eligible)
resource "aws_db_instance" "postgres_rds" {
  identifier             = "free-tier-postgres"
  engine                 = "postgres"
  engine_version         = "17.2.R2"     # Latest version supported in Free Tier
  instance_class         = "db.t3.micro" # Free Tier eligible
  allocated_storage      = 20            # Max for Free Tier
  storage_type           = "gp2"
  db_name                = "postgresdb-1" # Default database name
  username               = "postgres"     # Default PostgreSQL admin username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  # Free Tier appropriate settings
  backup_retention_period = 0 # Disable automatic backups to stay within Free Tier
  maintenance_window      = "Mon:00:00-Mon:03:00"
  deletion_protection     = false # Disable for easier cleanup (enable for production)

  tags = {
    Environment = "dev"
  }
}

# Output the RDS endpoint
output "postgres_endpoint" {
  value = aws_db_instance.postgres_rds.endpoint
}


