
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "sg" {
  name        = "ai-data-studio-sg"
  description = "Security group for AI Data Studio"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nitro_enclave" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "m6i.large"
  subnet_id     = aws_subnet.subnet.id
  security_groups = [aws_security_group.sg.name]

  enclave_options {
    enabled = true
  }

  tags = {
    Name = "ai-data-studio-nitro"
  }
}

resource "aws_kms_key" "kms" {
  description             = "KMS key for AI Data Studio"
  deletion_window_in_days = 10
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/ai-data-studio"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors high CPU usage"
  dimensions = {
    InstanceId = aws_instance.nitro_enclave.id
  }
}
