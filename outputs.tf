output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.python_ec2.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.python_ec2.id
}

output "application_url" {
  description = "Python Flask application URL"
  value       = "http://${aws_instance.python_ec2.public_ip}:8000"
}