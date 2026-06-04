
# -------------------------------
# 🔍 Get Latest Amazon Linux AMI
# -------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -------------------------------
# 🌐 VPC
# -------------------------------
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "my-vpc"
}

#----------------------------------
# @ IAM ROLE
#----------------------------------
module "iam" {
  source = "./modules/iam"
}

# -------------------------------
# 🌍 Subnet
# -------------------------------
#
#
#
# -------------------------------
# 🌍 Public Subnets
# -------------------------------
module "subnet1" {
  source                  = "./modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.1.0/24"
  subnet_name             = "public-subnet-1"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

module "subnet2" {
  source                  = "./modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.2.0/24"
  subnet_name             = "public-subnet-2"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

#-------------------------------
# NAT Gateway Module
#-------------------------------

module "nat_gateway" {
  source    = "./modules/nat_gateway"
  subnet_id = module.subnet1.subnet_id # public subnet
  name      = "main-nat"
}


#----------------------------------
# Private Route Table
#----------------------------------

module "private_route_table" {
  source = "./modules/private_route_table"

  vpc_id         = module.vpc.vpc_id
  nat_gateway_id = module.nat_gateway.nat_gateway_id

  subnet_ids = [
    module.app_subnet1.subnet_id,
    module.app_subnet2.subnet_id
  ]

  name = "app-private-rt"
}

# -------------------------------
# 🔒 Private App Subnets
# -------------------------------
module "app_subnet1" {
  source                  = "./modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.11.0/24"
  subnet_name             = "app-private-1"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

module "app_subnet2" {
  source                  = "./modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.12.0/24"
  subnet_name             = "app-private-2"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

# -------------------------------
# 🗄️ Private DB Subnets
# -------------------------------
module "db_subnet1" {
  source                  = "./modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.21.0/24"
  subnet_name             = "db-private-1"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

module "db_subnet2" {
  source                  = "./modules/subnet"
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = "10.0.22.0/24"
  subnet_name             = "db-private-2"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

#module "subnet" {
#  source      = "./modules/subnet"
#  vpc_id      = module.vpc.vpc_id
#  subnet_cidr = "10.0.1.0/24"
#  subnet_name = "public-subnet"
#}

# -------------------------------
# 🌐 Internet Gateway
# -------------------------------
module "igw" {
  source   = "./modules/igw"
  vpc_id   = module.vpc.vpc_id
  igw_name = "my-igw"
}

# -------------------------------
# 🛣️ Route Table
# -------------------------------
module "route_table" {
  source = "./modules/route_table"

  vpc_id  = module.vpc.vpc_id
  igw_id  = module.igw.igw_id
  rt_name = "public-rt"

  subnet_ids = [
    module.subnet1.subnet_id,
    module.subnet2.subnet_id
  ]
}

# -------------------------------
# 🔐 Security Group
# -------------------------------
module "sg" {
  source  = "./modules/sg"
  vpc_id  = module.vpc.vpc_id
  sg_name = "web-sg"
}

# -------------------------------
# 💻 EC2 Instance
# -------------------------------
#module "ec2" {
#  source          = "./modules/ec2"
#  subnet_id       = module.subnet.subnet_id
#  security_groups = [module.sg.sg_id]

#  ami             = data.aws_ami.amazon_linux.id
#  instance_type   = "t3.micro"
#  key_name        = "terraform-key"
#  instance_name   = "my-ec2"
#}

# --------------------------------
#  Launch Template
#---------------------------------
module "launch_template" {
  source                = "./modules/launch_template"
  ami                   = data.aws_ami.amazon_linux.id
  instance_type         = "t3.micro"
  key_name              = "terraform-key"
  security_groups       = [module.sg.sg_id]
  instance_profile_name = module.iam.instance_profile_name
}

#--------------------------------------
#   Tartget group
#--------------------------------------
module "target_group" {
  source = "./modules/target_group"
  vpc_id = module.vpc.vpc_id
}

#--------------------------------------
#   Application Load Balance (ALB)
#--------------------------------------
module "alb" {
  source          = "./modules/alb"
  security_groups = [module.sg.sg_id]
  subnets = [
    module.subnet1.subnet_id,
    module.subnet2.subnet_id
  ]
  target_group_arn = module.target_group.target_group_arn
}

#---------------------------------------
#   Auto Scaling Group
#---------------------------------------
module "asg" {
  source                  = "./modules/asg"
  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = tostring(module.launch_template.latest_version)
  subnets = [
    module.app_subnet1.subnet_id,
    module.app_subnet2.subnet_id
  ]
  target_group_arn = module.target_group.target_group_arn
}

# --------------------------------------
#   RDS Module (DB Layer)
# --------------------------------------
module "rds" {
  source = "./modules/rds"

  db_name  = "mydb"
  username = "admin"
  password = "Admin1234!" # later move to secrets

  vpc_id = module.vpc.vpc_id

  subnet_ids = [
    module.db_subnet1.subnet_id,
    module.db_subnet2.subnet_id
  ]

  app_sg_id = module.sg.sg_id
}

#-------------------------------------------

module "sns" {
  source = "./modules/sns"

  topic_name    = "terraform-alerts"
  email_address = "lalitha.tammi@gmail.com"
}

module "cloudwatch" {

  source = "./modules/cloudwatch"

  target_group_arn_suffix  = module.target_group.target_group_arn_suffix
  load_balancer_arn_suffix = module.alb.alb_arn_suffix

  sns_topic_arn = module.sns.topic_arn
}

module "dashboard" {

  source = "./modules/dashboard"

  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.target_group.target_group_arn_suffix
}
