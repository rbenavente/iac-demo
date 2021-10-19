terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name      = "tf-0.12-for-example"
    yor_trace = "72241a4c-cc60-4189-b03c-1a3fbb0c2188"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name      = "tf-0.12-for-example"
    yor_trace = "436b67d3-d1a0-468a-8954-fd9d1b7dd8b2"
  }
}

resource "aws_instance" "ubuntu" {
  count                       = 3
  ami                         = "ami-2e1ef954"
  instance_type               = "t2.micro"
  associate_public_ip_address = (count.index == 1 ? true : false)
  subnet_id                   = aws_subnet.my_subnet.id
  tags = {
    Name      = format("terraform-0.12-for-demo-%d", count.index)
    yor_trace = "85b149ae-e20c-4005-bcd7-94daafd7f826"
  }
}

# This uses the old splat expression
output "private_addresses_old" {
  value = aws_instance.ubuntu.*.private_dns
}

# This uses the new full splat operator (*)
# But this does not work in 0.12 alpha-1 or alpha-2
output "private_addresses_full_splat" {
  value = [aws_instance.ubuntu[*].private_dns]
}

# This uses the new for expression
output "private_addresses_new" {
  value = [
    for instance in aws_instance.ubuntu :
    instance.private_dns
  ]
}

# This uses the new conditional operator
# that can work with lists
# It should work with lists in [x, y, z] form, but does not yet do that
output "ips" {
  value = [
    for instance in aws_instance.ubuntu :
    (instance.public_ip != "" ? list(instance.private_ip, instance.public_ip) : list(instance.private_ip))
  ]
}

