// AWS specific variables
variable "aws_access_key" {
    default = ""
    description = "AWS access key (AWS_ACCESS_KEY_ID)"
}

variable "aws_secret_key" {
    default = ""
    description = "AWS secret key (AWS_SECRET_ACCESS_KEY)"
}

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