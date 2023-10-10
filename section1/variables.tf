# Declare variables for the front-end and back-end configurations
variable "frontend_bucket_name" {
  description = "The name of the S3 bucket for the front-end"
  type        = string
  default     = "my-bucket-siva"
}

variable "backend_instance_ami" {
  description = "The AMI ID for the EC2 instance running the back-end"
  type        = string
  default     = "ami-0fa7190e664488b99"
}


variable "subnet_id" {
  default = "subnet-03ba6a8fb3e1bde04"
  
}

variable "ssh_key_name" {
  default = "gitlab-private-key"
  
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {
    Environment = "Development",
    Application = "MyApp",
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {
    Owner = "Siva",
  }
}
