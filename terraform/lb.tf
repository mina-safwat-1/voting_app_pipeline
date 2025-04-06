resource "aws_lb" "test" {
  name     = "test-lb-tf"
  internal = false
  subnets = [
    for subnet in var.subnets :
    aws_subnet.subnets[subnet.name].id
    if subnet.type == "public"
  ]

  load_balancer_type         = "application"
  security_groups            = [aws_security_group.public_sg.id]
  enable_deletion_protection = false

}

