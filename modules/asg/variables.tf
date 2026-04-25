variable "launch_template_id" {}
variable "subnets" {}
variable "target_group_arn" {}
variable "launch_template_version" {
  description = "Launch template version"
  type        = string
}
