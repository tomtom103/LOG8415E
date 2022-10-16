// AWS specific variables
variable "aws_region" {
    description = "AWS region"
    type = string
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

variable "m4_instance_type" {
    description = "Instance type for large instances"
    type = string
    default = "m4.large"
}

variable "t2_instance_type" {
    description = "Instance type for small instances"
    type = string
    default = "t2.large" # TODO: Change this
}

variable "key_name" {
    description = "Name of the key pair to use"
    default = "vockey"
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type = map(string)
    default = {
        "Name" = "TP1"
        "Application" = "TP1"
        "Version" = "latest"
    }
}