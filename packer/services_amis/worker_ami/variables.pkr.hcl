variable base_ami_id {
  type    = string
}


variable container_image {
  type    = string
}


variable DB_USER {
  type    = string

}

variable DB_PASSWORD { 
  type    = string
}

variable DB_HOST {
  type    = string
}

variable REDIS_HOST {
  type    = string
}


variable aws_region {
  type    = string
  default = "us-east-1"
}
variable ecr_repository_url {
  type    = string
}

variable ec2_profile {
  type    = string
}