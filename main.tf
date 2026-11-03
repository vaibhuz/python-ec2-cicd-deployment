terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket       = "vaibhav-patil-s3"
    key          = "python-app/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "python_sg" {
  name        = "python-app-sg"
  description = "Security group for Python Flask application"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Python Application"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Python-App-SG"
  }
}

resource "aws_instance" "python_ec2" {
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type           = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids  = [aws_security_group.python_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install python3 python3-pip -y

    mkdir -p /opt/python-app
    chown ec2-user:ec2-user /opt/python-app

    cat > /etc/systemd/system/python-app.service <<'SERVICE'
    [Unit]
    Description=Python Flask Application
    After=network.target

    [Service]
    User=ec2-user
    WorkingDirectory=/opt/python-app
    ExecStart=/opt/python-app/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:80 app:app
    Restart=always

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable python-app
  EOF

  tags = {
    Name = "Python-Flask-EC2"
  }
}