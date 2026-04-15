# ALB, target groups, listeners, listener rules

# create application load balancer
resource "aws_lb" "main" {
    name = "${local.name_prefix}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_security_group.id]
    subnets = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
    tags = {
        Name = "${local.name_prefix}-alb"
    }
}

# create target group for the stable web server
resource "aws_lb_target_group" "stable_web_server_main" {
    name = "${local.name_prefix}-stable-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    health_check {
        path                = "/"
        protocol            = "HTTP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 10
    }
    tags = {
        Name = "${local.name_prefix}-stable-tg"
    }
}

# create target group for the canary web server
resource "aws_lb_target_group" "canary_web_server_tg" {
    name = "${local.name_prefix}-canary-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    health_check {
        path                = "/"
        protocol            = "HTTP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 10
    }
    tags = {
        Name = "${local.name_prefix}-canary-tg"
    }
}

# create target group attachments
resource "aws_lb_target_group_attachment" "stable_web_server_main" {
    target_group_arn = aws_lb_target_group.stable_web_server_main.arn
    target_id = aws_instance.stable_web_server_main.id
    port = 80
}

resource "aws_lb_target_group_attachment" "stable_web_server_backup" {
    target_group_arn = aws_lb_target_group.stable_web_server_main.arn
    target_id        = aws_instance.stable_web_server_backup.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "canary_web_server_tg" {
    target_group_arn = aws_lb_target_group.canary_web_server_tg.arn
    target_id = aws_instance.canary_server.id
    port = 80
}

# create HTTP listener with weighted routing
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"

        forward {
            target_group {
                arn = aws_lb_target_group.stable_web_server_main.arn
                weight = 90
            }
            target_group {
                arn = aws_lb_target_group.canary_web_server_tg.arn
                weight = 10
            }
        }
    }
}