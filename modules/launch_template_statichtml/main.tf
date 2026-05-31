resource "aws_launch_template" "lt" {
  name_prefix   = "my-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_groups
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  # 🔥 USER DATA (VERY IMPORTANT)
  user_data = base64encode(<<-EOF
#!/bin/bash

# Log everything
exec > /var/log/user-data.log 2>&1

yum update -y
yum install -y httpd mysql

systemctl enable httpd
systemctl start httpd

DB_HOST="my-rds-db.cwz268ocsmhm.us-east-1.rds.amazonaws.com"
DB_USER="admin"
DB_PASS="Admin1234!"
DB_NAME="mydb"

# Wait for DB to be ready
sleep 60

# Create test DB & table (first time only)
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS $DB_NAME;
USE $DB_NAME;
CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255)
);
INSERT INTO visitors (message) VALUES ("Hello from $(hostname -f)");
MYSQL_SCRIPT

# Fetch data
RESULT=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "SELECT * FROM $DB_NAME.visitors;" 2>/dev/null)

# Write to webpage
cat <<HTML > /var/www/html/index.html
<h1>3-Tier App Working ✅</h1>
<pre>$RESULT</pre>
HTML

EOF
  )
}
