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

          stat   = "Average"
          period = 60
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

          stat   = "Sum"
          period = 60
          region = "us-east-1"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title = "EC2 CPU Utilization"

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "i-0e92a55801fa263b2"
            ]
          ]

          stat   = "Average"
          period = 60
          region = "us-east-1"
        }
      },


      /*
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title = "Memory Utilization"

          metrics = [
            [
              "CWAgent",
              "mem_used_percent",
              "host",
              "ip-10-0-12-115.ec2.internal"
            ]
          ]

          stat   = "Average"
          period = 60
          region = "us-east-1"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title = "Disk Utilization"

          metrics = [
            [
              "CWAgent",
              "disk_used_percent",
              "host",
              "ip-10-0-12-115.ec2.internal",
              "path",
              "/",
              "device",
              "nvme0n1p1",
              "fstype",
              "xfs"
            ]
          ]

          stat   = "Average"
          period = 60
          region = "us-east-1"
        }
      }
*/
    ]
  })
}
