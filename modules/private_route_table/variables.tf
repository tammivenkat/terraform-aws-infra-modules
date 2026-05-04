variable "vpc_id" {}
variable "nat_gateway_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "name" {}
