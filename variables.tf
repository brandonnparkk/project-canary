# variables for the terraform configuration

variable "my_ip_address" {
    type = string
    description = "The IP address of the user"
}

variable "public_key" {
    type = string
    description = "SSH public key for EC2 access"
    sensitive = true
}