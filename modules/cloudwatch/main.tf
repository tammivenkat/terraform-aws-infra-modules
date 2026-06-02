resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {

  alarm_name          = "alb-healthy-host-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 2

  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.load_balancer_arn_suffix
  }

  alarm_description = "ALB healthy hosts dropped below 2"

  alarm_actions = [
    var.sns_topic_arn
  ]

  ok_actions = [
    var.sns_topic_arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {

  alarm_name          = "ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"

  period    = 60
  statistic = "Average"

  threshold = 80

  alarm_description = "EC2 CPU utilization above 80%"

  dimensions = {
    InstanceId = var.instance_id
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}
