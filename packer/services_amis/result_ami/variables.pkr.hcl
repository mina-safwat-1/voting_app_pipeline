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

variable DB_NAME {
  type    = string
  default = "postgres"
}

variable aws_region {
  type    = string
}
variable ecr_repository_url {
  type    = string
}

variable ec2_profile {
  type    = string
}