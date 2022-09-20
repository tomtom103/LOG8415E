// AWS specific variables
variable "aws_region" {
    description = "AWS region"
    default = "us-east-1"
}

variable "app_name" {
    description = "Name of the application"
    default = "TP1"
}

variable "api_version" {
    description = "Version of the API"
    default = "latest"
}

variable "vpc_id" {
    description = "VPC ID"
    default = "vpc-04a8518ca8d47a060"
}