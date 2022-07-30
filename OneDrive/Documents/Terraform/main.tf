resource "aws_vpc" "my-vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc1"
  }
}

resource "aws_subnet" "pb-subnet" {
  vpc_id     = aws_vpc.my-vpc1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pb-subnet"
  }
}

resource "aws_subnet" "pv-subnet" {
  vpc_id     = aws_vpc.my-vpc1.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "pv-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc1.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_eip" "EIP" {
  instance = aws_instance.pb-ec2.id
  vpc      = true
}

resource "aws_nat_gateway" "NAT-gw" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.pb-subnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "pb-sub-rout-tb" {
  vpc_id = aws_vpc.my-vpc1.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block  = "0.0.0.0/0"
  }

  tags = {
    Name = "example-1"
  }
}


/* output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
} */


resource "aws_instance" "pb-ec2" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"
  
  subnet_id   = aws_subnet.pb-subnet.id
  availability_zone = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.my-sg1.id]
  associate_public_ip_address = true

  tags = {
    Name = "pb-ec2"
  }
}


resource "aws_instance" "pv-ec2" {
  ami           = "ami-0cff7528ff583bf9a"
  instance_type = "t2.micro"
 
  subnet_id   = aws_subnet.pv-subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg1.id]
  availability_zone = "us-east-1b"

  tags = {
    Name = "pv-ec2"
  }

}

resource "aws_security_group" "my-sg1" {
  name = "my-sg1"
 vpc_id      = aws_vpc.my-vpc1.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.my-vpc1.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my-sg1"
  }
}



/* resource "aws_instance" "pv-ec2" {
  ami           =  ami-0cff7528ff583bf9a
  instance_type = "t2.micro"
  vpc_id        = aws_vpc.my-vpc1.id
  subnet_id   = aws_subnet.pv-subnet.id
  availability_zone = "us-east-1b"

  tags = {
    Name = "pv-ec2"
  }
} */