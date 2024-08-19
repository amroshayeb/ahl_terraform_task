# Public subnet EC2 instance 1
resource "aws_instance" "two-tier-web-server-1" {
  ami             = "ami-064eb0bee0c5402c5"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.two-tier-ec2-sg.id]
  subnet_id       = aws_subnet.two-tier-pub-sub-1.id
  key_name         = "two-tier-key"

  tags = {
    Name = "two-tier-web-server-1"
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

# Public subnet  EC2 instance 2
resource "aws_instance" "two-tier-web-server-2" {
  ami             = "ami-064eb0bee0c5402c5"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.two-tier-ec2-sg.id]
  subnet_id       = aws_subnet.two-tier-pub-sub-2.id
  key_name         = "two-tier-key"

  tags = {
    Name = "two-tier-web-server-2"
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

# EIP for instance 1
resource "aws_eip" "two-tier-web-server-1-eip" {
  vpc = true
  instance = aws_instance.two-tier-web-server-1.id
  depends_on = [aws_internet_gateway.two-tier-igw]
}

# EIP for instance 2
resource "aws_eip" "two-tier-web-server-2-eip" {
  vpc = true  
  instance = aws_instance.two-tier-web-server-2.id
  depends_on = [aws_internet_gateway.two-tier-igw]
}

# CloudWatch Alarm for EC2 Instance 1 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_high_two_tier_web_server_1" {
  alarm_name          = "High_CPU_Utilization_two_tier_web_server_1"
  alarm_description   = "This alarm triggers when CPU utilization exceeds 80% for instance two-tier-web-server-1."
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions = {
    InstanceId = aws_instance.two-tier-web-server-1.id
  }
  statistic           = "Average"
  period              = "300"
  threshold           = "80"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

# CloudWatch Alarm for EC2 Instance 2 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_high_two_tier_web_server_2" {
  alarm_name          = "High_CPU_Utilization_two_tier_web_server_2"
  alarm_description   = "This alarm triggers when CPU utilization exceeds 80% for instance two-tier-web-server-2."
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions = {
    InstanceId = aws_instance.two-tier-web-server-2.id
  }
  statistic           = "Average"
  period              = "300"
  threshold           = "80"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alerts" {
  name = "alerts"
}

# SNS Subscription for Alarms
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "shayebamr@gmail.com"  # Replace with your email address
}

