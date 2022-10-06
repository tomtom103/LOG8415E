# Network-related data
data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "all" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

# Data used by S3 bucket for ELB logs
data "aws_elb_service_account" "this" {}

data "aws_iam_policy_document" "logs" {
    statement {
        actions = [
            "s3:PutObject",
        ]
        principals {
            type = "AWS"
            identifiers = [data.aws_elb_service_account.this.arn]
        }

        resources = [
            "arn:aws:s3:::alb-logs-${random_pet.this.id}/*",
        ]
    }
}