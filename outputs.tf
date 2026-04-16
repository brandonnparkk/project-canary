# all outputs, these are the values that are outputted after the plan is applied

# bastion gets a dynamic public IP assigned by AWS at launch
# we don't know the IP address until the instance is created
output "bastion_host_public_ip" {
    value = aws_instance.bastion_host.public_ip
}

# ALB gets a static DNS name assigned by AWS at launch
# we know the DNS name before the ALB is created
output "alb_dns_name" {
    value = aws_lb.main.dns_name
}

output "stable_main_private_ip" {
    value = aws_instance.stable_web_server_main.private_ip
}

output "stable_backup_private_ip" {
    value = aws_instance.stable_web_server_backup.private_ip
}

output "canary_server_private_ip" {
    value = aws_instance.canary_server.private_ip
}