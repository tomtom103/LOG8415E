resource "random_pet" "this" {
    length = 2
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "all" {
    filter {
        name = "vpc-id"
        values = [var.vpc_id]
    }
}

# S3 bucket for ELB logs
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
            "arn:aws:s3:::elb-logs-${random_pet.this.id}/*",
        ]
    }
}

resource "aws_s3_bucket" "elb_logs" {
    bucket = "elb-logs-${random_pet.this.id}"
    force_destroy = true
}

resource "aws_s3_bucket_policy" "elb_logs_policy" {
    bucket = aws_s3_bucket.elb_logs.id
    policy = data.aws_iam_policy_document.logs.json
}



resource "aws_s3_bucket_acl" "elb_logs_acl" {
    bucket = aws_s3_bucket.elb_logs.id
    acl = "private"
}


module "elb" {
    source = "terraform-aws-modules/elb/aws"
    version = "3.0.1"

    name = "${var.app_name}-${var.api_version}"
    
    subnets = data.aws_subnets.all.ids

    security_groups = [
        aws_security_group.everywhere.id
    ]

    listener = [
        {
            instance_port = 80
            instance_protocol = "http"
            lb_port = 80
            lb_protocol = "http"
        },
        {
            instance_port = 80
            instance_protocol = "http"
            lb_port = 81
            lb_protocol = "http"
        }
    ]

    health_check = {
        target = "HTTP:80/"
        interval = 30
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 5
    }

    tags = var.common_tags
}