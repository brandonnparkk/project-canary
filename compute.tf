# EC2 instances, bastion, key pairs


# aws ami id for the ec2 instances
data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["al2023-ami-*-x86_64"]
    }
}

# create ec2 instance for the ec2 stable web server
resource "aws_instance" "stable_web_server_main" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.private_subnet_1a.id
    vpc_security_group_ids = [aws_security_group.app_security_group.id]
    key_name = aws_key_pair.bastion_host_key_pair.key_name
    user_data = <<-EOF
              #!/bin/bash
              mkdir -p /var/www/html
              echo "Hello World" > /var/www/html/index.html
              cd /var/www/html
              nohup python3 -m http.server 80 &
              EOF
    tags = {
        Name = "${local.name_prefix}-stable-web-server"
    }
}

# create ec2 instance for the ec2 stable web server
resource "aws_instance" "stable_web_server_backup" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.private_subnet_1b.id
    vpc_security_group_ids = [aws_security_group.app_security_group.id]
    key_name = aws_key_pair.bastion_host_key_pair.key_name
    user_data = <<-EOF
              #!/bin/bash
              mkdir -p /var/www/html
              echo "Hello World" > /var/www/html/index.html
              cd /var/www/html
              nohup python3 -m http.server 80 &
              EOF
    tags = {
        Name = "${local.name_prefix}-stable-web-server-backup"
    }
}

# create ec2 instance for the ec2 canary server
resource "aws_instance" "canary_server" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.private_subnet_1a.id
    vpc_security_group_ids = [aws_security_group.app_security_group.id]
    key_name = aws_key_pair.bastion_host_key_pair.key_name
    user_data = <<-EOF
              #!/bin/bash
              mkdir -p /var/www/html
              echo "World Hello" > /var/www/html/index.html
              cd /var/www/html
              nohup python3 -m http.server 80 &
              EOF
    tags = {
        Name = "${local.name_prefix}-canary-server"
    }
}

# create bastion host
resource "aws_instance" "bastion_host" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.public_subnet_1a.id
    key_name = aws_key_pair.bastion_host_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
    tags = {
        Name = "${local.name_prefix}-bastion-host"
    }
}

# create key pair for the bastion host
resource "aws_key_pair" "bastion_host_key_pair" {
    key_name = "${local.name_prefix}-bastion-host-key-pair"
    public_key = var.public_key
}