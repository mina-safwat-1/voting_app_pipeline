variable base_ami_id {
  type    = string
  default = "ami-0413f1851fbe6001a"
}


variable container_image {
  type    = string
  default = "194722415730.dkr.ecr.us-east-1.amazonaws.com/worker:latest"
}


variable DB_USER {
  type    = string
  default = "postgres"

}

variable DB_PASSWORD { 
  type    = string
  default = "postgres"
}

variable DB_HOST {
  type    = string
  default = "free-tier-postgres.ci98ky4msfdc.us-east-1.rds.amazonaws.com"
}

variable REDIS_HOST {
  type    = string
  default = "free-tier-redis.zuxuv6.0001.use1.cache.amazonaws.com"
}


variable aws_region {
  type    = string
  default = "us-east-1"
}
variable ecr_repository_url {
  type    = string
  default = "194722415730.dkr.ecr.us-east-1.amazonaws.com"
}

variable ec2_profile {
  type    = string
  default = "ecr-access-instance-profile"
}