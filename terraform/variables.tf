variable "subnets" {
  type = list(object({
    name       = string
    cidr_block = string
    type       = string
    az         = string
  }))
}


variable "region" {
  type    = string
  default = "us-east-1"
}

variable "worker_ami" {
    type    = string  
}