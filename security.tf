#  security groups, key pairs, etc.

# ===============================================
#  ALB Security Group
# ===============================================
# Create a security group for the ALB
resource "aws_security_group" "alb_security_group" {
    name = "alb_security_group"
    description = "Allows HTTPS inbound traffic and HTTP inbound traffic and all outbound traffic"
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-alb-security-group"
    }
}

#  Ingress rules for the ALB HTTPS
resource "aws_security_group_ingress_rule" "alb_ingress_https_traffic" {
    security_group_id = aws_security_group.alb_security_group.id
    cidr_ipv4 = var.my_ip_address
    from_port = 443
    ip_protocol = "tcp"
    to_port = 443
    tags = {
        Name = "${local.name_prefix}-alb-ingress-https-traffic"
    }
}

#  Ingress rules for the ALB HTTP
resource "aws_security_group_ingress_rule" "alb_ingress_http_traffic" {
    security_group_id = aws_security_group.alb_security_group.id
    cidr_ipv4 = var.my_ip_address
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
    tags = {
        Name = "${local.name_prefix}-alb-ingress-http-traffic"
    }
}

# Egress rules for the ALB
resource "aws_security_group_egress_rule" "alb_egress_traffic" {
    security_group_id = aws_security_group.alb_security_group.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
    tags = {
        Name = "${local.name_prefix}-alb-egress-traffic"
    }
}

# ===============================================
#  Bastion host Security Group
# ===============================================
# Create a security group for the Bastion host
resource "aws_security_group" "bastion_security_group" {
    name = "bastion_security_group"
    description = "Allows SSH inbound traffic from my IP address and all outbound traffic"
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-bastion-security-group"
    }
}

# Ingress rules for the Bastion host
resource "aws_security_group_ingress_rule" "bastion_ingress_ssh_traffic" {
    security_group_id = aws_security_group.bastion_security_group.id
    cidr_ipv4 = var.my_ip_address
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
    tags = {
        Name = "${local.name_prefix}-bastion-ingress-ssh-traffic"
    }
}

# Egress rules for the Bastion host
resource "aws_security_group_egress_rule" "bastion_egress_traffic" {
    security_group_id = aws_security_group.bastion_security_group.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
    tags = {
        Name = "${local.name_prefix}-bastion-egress-traffic"
    }
}

# ===============================================
#  Application server Security Group
# ===============================================
# Create a security group for the Application server
resource "aws_security_group" "app_security_group" {
    name = "app_security_group"
    description = "Allows inbound traffic from the ALB and inbound traffic from the Bastion host"
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${local.name_prefix}-app-security-group"
    }
}

# Ingress rules for the Application server from the ALB
resource "aws_security_group_ingress_rule" "app_ingress_http" {
    security_group_id = aws_security_group.app_security_group.id
    referenced_security_group_id = aws_security_group.alb_security_group.id
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
    tags = {
        Name = "${local.name_prefix}-app-ingress-http-traffic"
    }
}

# Ingress rules for the Application server from the Bastion host
resource "aws_security_group_ingress_rule" "app_ingress_ssh" {
    security_group_id = aws_security_group.app_security_group.id
    referenced_security_group_id = aws_security_group.bastion_security_group.id
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
    tags = {
        Name = "${local.name_prefix}-app-ingress-ssh-traffic"
    }
}

# Egress rules for the Application server
resource "aws_security_group_egress_rule" "app_egress_traffic" {
    security_group_id = aws_security_group.app_security_group.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
    tags = {
        Name = "${local.name_prefix}-app-egress-traffic"
    }
}
