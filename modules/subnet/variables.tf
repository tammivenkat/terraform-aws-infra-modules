variable "vpc_id" {
  description = "VPC ID from VPC module"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "availability_zone" {}
