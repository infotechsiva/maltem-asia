output "instance_private_ip" {
  value = aws_instance.back_end_instance.private_ip
}

output "ec2_instance_public_dns" {
  description = "The public DNS of the EC2 instance for the back-end"
  value       = aws_instance.back_end_instance.public_dns
}

output "cloudfront_distribution_url" {
  description = "The URL of the CloudFront distribution for the front-end"
  value       = aws_cloudfront_distribution.front_end_distribution.domain_name
}