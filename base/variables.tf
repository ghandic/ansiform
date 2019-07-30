# AWS Config

variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}

variable "public_key_path" {
  default = "/keys/MyLearningInstance.pem"
}

variable "key_name" {
  default = "MyLearningInstance"
}

variable "ubuntu_account_number" {
  default = "099720109477"
}

variable "amazon_account_number" {
  default = "137112412989"
}