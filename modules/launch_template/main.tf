resource "aws_launch_template" "lt" {
  name_prefix   = "my-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_groups
  }

  # 🔥 USER DATA (VERY IMPORTANT)

  user_data = base64encode(<<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1

yum update -y
yum install -y httpd

systemctl enable httpd
systemctl start httpd

echo "Hello from Amazone Linux OS Machine ASG - $(hostname -f)" > /var/www/html/index.html
EOF
  )


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "asg-instance"
    }
  }
}
