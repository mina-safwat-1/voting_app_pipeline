variable base_ami_id {
  type    = string
  default = "ami-0e8c3342f93397f86"
}


variable service_name {
  type    = string
  default = "worker"
}

variable container_name {
  type    = string
  default = "nginx"
}

variable container_image {
  type    = string
  default = "nginx"
}