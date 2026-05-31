variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "security_groups" {}
variable "instance_profile_name" {
  description = "IAM Instance Profile"
  type        = string
}
