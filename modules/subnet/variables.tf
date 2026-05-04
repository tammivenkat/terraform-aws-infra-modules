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

variable "availability_zone" {
  description = "Subnet Availability Zone"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Auto assign public IP"
  type        = bool
  default     = false
}
