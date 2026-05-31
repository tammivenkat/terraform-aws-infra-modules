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

  user_data = base64encode(<<-EOF
#!/bin/bash

# Logging
exec > /var/log/user-data.log 2>&1
set -xe

echo "========== USER DATA START =========="

# System update
yum update -y

# Enable PHP 8.2
#amazon-linux-extras enable php8.2

amazon-linux-extras install php8.2 -y

yum clean metadata

# Install required packages
yum install -y \
  httpd \
  php \
  php-cli \
  php-mysqlnd \
  mariadb105 \
  awscli

# Start Apache
systemctl enable httpd
systemctl start httpd

# Remove Apache default page
rm -f /var/www/html/index.html

echo "========== FETCHING SSM PARAMETERS =========="

# Fetch DB details from SSM Parameter Store
DB_HOST=$(aws ssm get-parameter \
  --name /myapp/db/host \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

DB_USER=$(aws ssm get-parameter \
  --name /myapp/db/username \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

DB_PASS=$(aws ssm get-parameter \
  --name /myapp/db/password \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

DB_NAME="mydb"

echo "DB_HOST=$DB_HOST"
echo "DB_USER=$DB_USER"

# Validate parameters
if [ -z "$DB_HOST" ]; then
  echo "ERROR: DB_HOST is empty"
  exit 1
fi

# Wait for RDS DNS and connectivity
echo "========== WAITING FOR RDS =========="

for i in {1..30}; do
  nslookup $DB_HOST && break
  echo "Waiting for DNS resolution..."
  sleep 10
done

# Create PHP application
echo "========== CREATING PHP APPLICATION =========="

cat <<PHP > /var/www/html/index.php
<?php

\$host = "$DB_HOST";
\$user = "$DB_USER";
\$pass = "$DB_PASS";
\$db   = "$DB_NAME";

\$conn = new mysqli(\$host, \$user, \$pass);

if (\$conn->connect_error) {
    die("DB Connection Failed: " . \$conn->connect_error);
}

\$conn->query("CREATE DATABASE IF NOT EXISTS \$db");

\$conn->select_db(\$db);

\$conn->query("
CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255)
)
");

\$hostname = gethostname();

\$conn->query("
INSERT INTO visitors(message)
VALUES ('Hello from \$hostname')
");

\$result = \$conn->query("SELECT * FROM visitors");

echo "<h1>3-Tier Dynamic App ✅</h1>";
echo "<h3>Hostname: \$hostname</h3>";
echo "<pre>";

while(\$row = \$result->fetch_assoc()) {
    echo \$row['id'] . ' ' . \$row['message'] . PHP_EOL;
}

echo "</pre>";

?>
PHP

# Set permissions
chown apache:apache /var/www/html/index.php

# Restart Apache
systemctl restart httpd

echo "========== USER DATA COMPLETED =========="
EOF
  )
}
