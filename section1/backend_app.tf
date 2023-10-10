# Create an IAM role for the EC2 instance with read access to the frontend S3 bucket
resource "aws_iam_role" "back_end_role" {
  name = "back-end-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags   = merge(var.common_tags, var.additional_tags, { sub-component = "backend" })
}

# Attach an inline policy to the IAM role to grant read access to the frontend S3 bucket
resource "aws_iam_policy" "s3_read_policy" {
  name = "s3-read-policy"

  description = "Policy to allow read access to the frontend S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.frontend_bucket_name}/*"
      },
      {
        Action   = "s3:ListBucket",
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.frontend_bucket_name}"
      }
    ]
  })
  tags   = merge(var.common_tags, var.additional_tags, { sub-component = "backend" })
}

# Attach the inline policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_read_policy_attachment" {
  policy_arn = aws_iam_policy.s3_read_policy.arn
  role       = aws_iam_role.back_end_role.name
}

resource "aws_iam_instance_profile" "back_end_profile" {
  name = "back-end-profile"

  # Attach IAM roles as needed
  role = aws_iam_role.back_end_role.name
  tags   = merge(var.common_tags, var.additional_tags, { sub-component = "backend" })
}



# Define a security group for the back-end
resource "aws_security_group" "back_end_sg" {
  name_prefix = "back-end-sg-"

  # Inbound rule allowing port 8080 from 0.0.0.0/0
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#    ingress {
#     from_port   = 8090
#     to_port     = 8090  # Same as the from_port
#     protocol    = "tcp"
#     security_groups = ["other-security-group-id"]  ## if this backend server is accssible from ALB or any other server this SG id of that ALB or server
#   }

  # Outbound rule allowing ephemeral ports (1024-65535) to the world
  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags   = merge(var.common_tags, var.additional_tags, { sub-component = "backend" })
}



# Create an EC2 instance for the back-end
resource "aws_instance" "back_end_instance" {
  ami           = var.backend_instance_ami
  instance_type = "t2.micro" # Replace with your desired instance type
  key_name      = var.ssh_key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.back_end_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.back_end_profile.name

  # Adding user data script to configure tomcat which is listening on 8090 for back-end application
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y tomcat8
              sudo systemctl enable tomcat8
              sudo systemctl start tomcat8
              sudo systemctl status tomcat8

              ## Adjust Tomcat server.xml to listen on port 8090
              sudo sed -i 's/<Connector port="8080"/<Connector port="8090"/' /etc/tomcat8/server.xml
              sudo systemctl restart tomcat8
              EOF

  tags   = merge(var.common_tags, var.additional_tags, { sub-component = "backend" })
}
