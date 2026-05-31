resource "aws_cloudwatch_dashboard" "main" {

  dashboard_name = "terraform-3tier-dashboard"

  dashboard_body = jsonencode({

    widgets = [

      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {

          title = "ALB Healthy Hosts"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "TargetGroup", var.target_group_arn_suffix,
              "LoadBalancer", var.alb_arn_suffix
            ]
          ]

          period = 60
          stat   = "Average"
          region = "us-east-1"
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {

          title = "ALB Request Count"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer", var.alb_arn_suffix
            ]
          ]

          period = 60
          stat   = "Sum"
          region = "us-east-1"
        }
      }
    ]
  })
}
