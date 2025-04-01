region         = "us-east-1"
subnets = [
  {
    name       = "pub_subnet_1"
    cidr_block = "10.0.0.0/24"
    type       = "public"
    az         = "a"
  },
  {
    name       = "pub_subnet_2"
    cidr_block = "10.0.1.0/24"
    type       = "public"
    az         = "b"

  },
  {

    name       = "priv_subnet_1"
    cidr_block = "10.0.2.0/24"
    type       = "private"
    az         = "a"

  },
  {
    name       = "priv_subnet_2"
    cidr_block = "10.0.3.0/24"
    type       = "private"
    az         = "b"

  }
]

worker_ami = "ami-0ebbb5163d7979adb"

# worker_ami = "ami-071226ecf16aa7d96"

# worker_ami = "ami-084568db4383264d4"
