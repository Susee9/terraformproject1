# Not manadatory but better to mention it
terraform {

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }

  # s3 bucket has to be created in aws console only by terraform we cannot create s3 bucket
  # s3 bucket name has to be unique in the world
    
/*   backend "s3" {
    bucket = "terraform-susee-bucket"
    key    = "terraform_state_file"
    region = "ap-south-1"
  }
 */
}

provider "aws" {
  region = "ap-south-1"
}

# C:\Repo\Terraform_project1 - path for terraform scripts
# /c/users/lenovo/.ssh     - path for key pair id_ed25519
# https://github.com/amolshete/terraform-code/blob/main/infra.tf

#Creation of VPC
resource "aws_vpc" "tproject1-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tproject1-vpc"
  }
}

#Creation of Subnets in ap-south-1a region(public subnet)
resource "aws_subnet" "tproject1_subnet_1a_pu" {
  vpc_id     = aws_vpc.tproject1-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tproject1_subnet_1a_pu"
  }
}


#Creation of Subnets in ap-south-1a region(private subnet, we are not giving ap_public_ip_on_launch)
resource "aws_subnet" "tproject1_subnet_1a_pr" {
  vpc_id     = aws_vpc.tproject1-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "tproject1_subnet_1a_pr"
  }
}

#Creation of Subnets in ap-south-1b region (public subnet)
resource "aws_subnet" "tproject1_subnet_1b_pu" {
  vpc_id     = aws_vpc.tproject1-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tproject1_subnet_1b_pu"
  }
}


#Creation of Subnets in ap-south-1b region(private subnet, we are not giving ap_public_ip_on_launch)
resource "aws_subnet" "tproject1_subnet_1b_pr" {
  vpc_id     = aws_vpc.tproject1-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "tproject1_subnet_1b_pr"
  }
}

# Creating Ec2 machine
resource "aws_instance" "tproject1_instance_1" {
  ami           = "ami-0e0ef0fdc582e5acd"# ami-007020fd9c84e18c7 is the ami id for ubuntu
  # ami-0e0ef0fdc582e5acd of apache preinstalled image the ami id is apache-preinstalled-image
  instance_type = "t2.micro"
  key_name = aws_key_pair.tproject1-keypair.id # check this once if key pair is connecting or not
  subnet_id = aws_subnet.tproject1_subnet_1a_pu.id #
  associate_public_ip_address="true" # this will create public ip when instance is created
  vpc_security_group_ids = [aws_security_group.tproject1_security_gp.id] #
  user_data = filebase64("userdata.sh") 

  tags = {
    Name = "tproject1_instance_1"
    owner="Suseela Devi"
  }
}

# Creating Ec2 machine
resource "aws_instance" "tproject1_instance_2" {
  ami           = "ami-0e0ef0fdc582e5acd"# ami-007020fd9c84e18c7 is the ami id for ubuntu
  # ami-0e0ef0fdc582e5acd of apache preinstalled image the ami id is apache-preinstalled-image
  instance_type = "t2.micro"
  key_name = aws_key_pair.tproject1-keypair.id # check this once if key pair is connecting or not
  subnet_id = aws_subnet.tproject1_subnet_1b_pu.id #
  associate_public_ip_address="true" # this will create public ip when instance is created
  vpc_security_group_ids = [aws_security_group.tproject1_security_gp.id] #
  user_data = filebase64("userdata.sh") 

  tags = {
    Name = "tproject1_instance_2"
    owner="Suseela Devi"
  }
}

# Creating Key Pair
resource "aws_key_pair" "tproject1-keypair" {
  key_name   = "tproject1-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCdcXyiJZrpsbkw3G4lSXk85NW5mbO8/pjQFzt86i+5tK/ixb4YiewjxhZ2vxfg/SHBlv2rANVJCfiNv18OTZ9VyapT0NqCULBy8muzI8N2zxnNjVfJPMwOEkY2E5R1wygtFdQe8YWmSUcnVYo3CBSvUTTuBjCZQIqBX3MxKOqLBk22QIp5Jef3aFBDE37t8xac1QP0vNnwhj0KSCTuHeWHo/aJg4G9NVcohClfCDRj5CShkaX/0rYEKKAIwIC0jEkn4vKX1YnqxBXjQBPJQ8g91lnvqPC/Hsx3ZGJTzXq9PCVEoT6pqJUuBDiCCVMOvoChjq3IuwOxP+Dl2dkTK/AoOjCtwp2UnrXiUODGHLUNWmlt685Xq4IBHSNeJruZW99VJ6iZpHJKUp10N4wpKvN4cvPlNfms89wVOeN/O5a+T/jALy1wp5s4rT0QZEc+x7XPj4ptUxiOGsjbWVkoe5SwkIS5nlfnKuyDEqfWV7N8wzVLQLc8K3LV47oeyUcp4xs= lenovo@DESKTOP-UFV1MS4"
}

# Creation of security group
resource "aws_security_group" "tproject1_security_gp" {
  name        = "tproject1_security_gp"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.tproject1-vpc.id

  tags = {
    Name = "allow_traffic_for_ec2_instance_pr1"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tproject1_ssh_22" {
  security_group_id = aws_security_group.tproject1_security_gp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "tproject1_ssh_80" {
  security_group_id = aws_security_group.tproject1_security_gp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "tproject1_all_traffic_ipv4" {
  security_group_id = aws_security_group.tproject1_security_gp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # -1 semantically equivalent to all ports
}

# Creation of internet gateway
resource "aws_internet_gateway" "tproject1_internet_gateway" {
  vpc_id = aws_vpc.tproject1-vpc.id

  tags = {
    Name = "tproject1_internet_gateway"
  }
}

#Creation of public Route Table

resource "aws_route_table" "tproject1_public_route_table" {
  vpc_id = aws_vpc.tproject1-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tproject1_internet_gateway.id
  }
  
  tags = {
    Name = "tproject1_public_route_table"
  }
}

#aws subnet association
resource "aws_route_table_association" "tproject1_RT_assoc_1a_pu" {
  subnet_id      = aws_subnet.tproject1_subnet_1a_pu.id
  route_table_id = aws_route_table.tproject1_public_route_table.id
}

#aws subnet association
resource "aws_route_table_association" "tproject1_RT_assoc_1b_pu" {
  subnet_id      = aws_subnet.tproject1_subnet_1b_pu.id
  route_table_id = aws_route_table.tproject1_public_route_table.id
}

#Creation of private Route Table

resource "aws_route_table" "tproject1_private_route_table" {
  vpc_id = aws_vpc.tproject1-vpc.id
  
  tags = {
    Name = "tproject1_private_route_table"
  }
}

#aws private subnet terrform_subnet_1a_pr association

resource "aws_route_table_association" "tproject1_RT_assoc_1a_pr" {
  subnet_id      = aws_subnet.tproject1_subnet_1a_pr.id
  route_table_id = aws_route_table.tproject1_private_route_table.id
}

#aws private subnet terrform_subnet_1b_pr association

resource "aws_route_table_association" "tproject1_RT_assoc_1b_pr" {
  subnet_id      = aws_subnet.tproject1_subnet_1b_pr.id
  route_table_id = aws_route_table.tproject1_private_route_table.id
}

# Creation of terraform target group 
resource "aws_lb_target_group" "tproject1-tg" {
  name     = "tproject1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tproject1-vpc.id
}

# Creation of terraform target group asscocation with ec2 instance, instance name is terraform_instance_main_1
resource "aws_lb_target_group_attachment" "tproject1_ec2_ass_1" {
  target_group_arn = aws_lb_target_group.tproject1-tg.arn
  target_id        = aws_instance.tproject1_instance_1.id
  port             = 80
}

# Creation of terraform target group asscocation with ec2 instance, instance name is terraform_instance_main_2
resource "aws_lb_target_group_attachment" "tproject1_ec2_ass_2" {
  target_group_arn = aws_lb_target_group.tproject1-tg.arn
  target_id        = aws_instance.tproject1_instance_2.id
  port             = 80
}

# Creation of load balancer
resource "aws_lb" "tproject1-loadbalancer" {
  name               = "tproject1-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tproject1_security_gp.id] # in [] we can mention multiple security groups
  subnets            = [aws_subnet.tproject1_subnet_1a_pu.id, aws_subnet.tproject1_subnet_1b_pu.id]

}

# Creation of listener
resource "aws_lb_listener" "tproject1-listener" {
  load_balancer_arn = aws_lb.tproject1-loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tproject1-tg.arn
  }
} 

#Creating the launch template

resource "aws_launch_template" "tproject1_launch_template" {

  name = "tproject1_launch_template"
  image_id = "ami-0e0ef0fdc582e5acd" 
  # image_id is the ami id tken from image creation that is image created after installing apache
  instance_type = "t2.micro"
  key_name = aws_key_pair.tproject1-keypair.id
  vpc_security_group_ids = [aws_security_group.tproject1_security_gp.id]

  tag_specifications {
    resource_type = "tproject1-instance"

    tags = {
      Name = "tproject1_demo_instance_by_LT"
    }
  }

 /*  tags = {
    Name = "terraform_instance_main_2"
    owner= "Suseela Devi"
  }
 */
  user_data = filebase64("userdata.sh")
}

# auto scaling group (ASG)
resource "aws_autoscaling_group" "terraform_asg" {

  name               = "tproject1_asg"
  vpc_zone_identifier = [aws_subnet.tproject1_subnet_1a_pu.id, aws_subnet.tproject1_subnet_1b_pu.id]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  target_group_arns = [aws_lb_target_group.tproject1-tg.arns]

  launch_template {
    id      = aws_launch_template.tproject1_launch_template.id
    version = "$Latest"
  }
}

# Creation of auto scaling group load balancer (ALB with ASG)
resource "aws_lb" "tproject1-load-balancer-asg" {
  name               = "tproject1-load-balancer-asg"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tproject1_security_gp.id] # in [] we can mention multiple security groups
  subnets            = [aws_subnet.tproject1_subnet_1a_pu.id, aws_subnet.tproject1_subnet_1b_pu]

}

# Creation of ASG listener
resource "aws_lb_listener" "tproject1_asg_listener" {
  load_balancer_arn = aws_lb.tproject1-load-balancer-asg.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tproject1-tg.arn
  }
}