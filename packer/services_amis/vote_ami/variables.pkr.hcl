variable base_ami_id {
  type    = string
  default = "ami-0e8c3342f93397f86"
}

variable container_image {
  type    = string
  default = "nginx"
}

variable REDIS_HOST {
  type    = string
}