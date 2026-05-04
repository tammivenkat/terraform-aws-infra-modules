resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 2

  vpc_zone_identifier = var.subnets

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  target_group_arns = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 180

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}
