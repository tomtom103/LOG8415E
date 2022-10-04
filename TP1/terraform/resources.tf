# Allows us to generate a random string
resource "random_pet" "this" {
    length = 2
}

## S3 Bucket for ELB logs
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

## ELB Instance
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

## Security Group
resource "aws_security_group" "everywhere" {
    name   = "everywhere"
    vpc_id = "${data.aws_vpc.default.id}"

    ingress {
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = "0"
        to_port     = "0"
    }
    egress {
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = "0"
        to_port     = "0"
    }

    tags = var.common_tags
}

## EC2 Instances
resource "aws_instance" "large" {
    count = var.number_of_instances

    instance_type = "${var.large_instance_type}"
    tags = var.common_tags

    key_name = "${var.key_name}"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), count.index)

    ami = "ami-026b57f3c383c2eec"
}

resource "aws_instance" "small" {
    count = var.number_of_instances

    instance_type = "${var.small_instance_type}"
    tags = var.common_tags
    key_name = "${var.key_name}"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), count.index)

    ami = "ami-026b57f3c383c2eec"
}

## Target Groups used to attach EC2 instances to ELB
resource "aws_lb_target_group" "cluster1" {
    name = "cluster1"
    port = 80
    protocol = "HTTP"
    vpc_id = "${data.aws_vpc.default.id}"
}

resource "aws_lb_target_group" "cluster2" {
    name = "cluster2"
    port = 80
    protocol = "HTTP"
    vpc_id = "${data.aws_vpc.default.id}"
}


module "aws_elb_attachment_large" {
  source  = "terraform-aws-modules/elb/aws//modules/elb_attachment"
  version = "3.0.1"
  
  elb = "${module.elb.elb_id}"
  instances = aws_instance.large.*.id
  number_of_instances = var.number_of_instances
}

module "aws_elb_attachment_small" {
  source  = "terraform-aws-modules/elb/aws//modules/elb_attachment"
  version = "3.0.1"
  
  elb = "${module.elb.elb_id}"
  instances = aws_instance.small.*.id
  number_of_instances = var.number_of_instances
}
