# Allows us to generate a random string
resource "random_pet" "this" {
    length = 2
}

## S3 Bucket for ALB logs
resource "aws_s3_bucket" "alb_logs" {
    bucket = "alb-logs-${random_pet.this.id}"
    force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
    bucket = aws_s3_bucket.alb_logs.id
    policy = data.aws_iam_policy_document.logs.json
}

resource "aws_s3_bucket_acl" "alb_logs_acl" {
    bucket = aws_s3_bucket.alb_logs.id
    acl = "private"
}

## ALB Instance
resource "aws_alb" "alb" {  
  name               = "${var.app_name}-${var.api_version}"
  internal           = false
  security_groups    = [aws_security_group.everywhere.id]
  subnets            = data.aws_subnets.all.ids

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
  }

  tags = var.common_tags
}
## ALB listener
resource "aws_alb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_alb.alb.arn}"  
  port              = "80"  
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    forward {
      dynamic "target_group" {
        for_each = ["cluster1", "cluster2"]
        content {
          arn = aws_alb_target_group.clusters[target_group.value].arn
        }
      }
    }
  }

}

resource "aws_alb_listener_rule" "listener_rule" {
  
  listener_arn = "${aws_alb_listener.alb_listener.arn}"
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.clusters["cluster1"].arn}"
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.clusters["cluster2"].arn}"
  }
  condition {
    path_pattern {
    values = ["*"]    
    }
  }
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

## Target Groups used to attach EC2 instances to ALB
resource "aws_alb_target_group" "clusters" {
    for_each = toset(["cluster1", "cluster2"])
    name = each.value
    port = "80"
    protocol = "HTTP"
    vpc_id = "${data.aws_vpc.default.id}"
    tags = var.common_tags

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 10
        timeout = 5
        interval = 30
        path = "/"
        port = "80"
        protocol = "HTTP"
    }
}


## ALB Attachment
resource "aws_alb_target_group_attachment" "cluster1" {
    for_each = {
        for i in range(0, var.number_of_instances) : "${i}" => i
    }
    target_group_arn = aws_alb_target_group.clusters["cluster1"].arn
    target_id = aws_instance.large[each.value].id
}

resource "aws_alb_target_group_attachment" "cluster2" {
    for_each = {
        for i in range(0, var.number_of_instances) : "${i}" => i
    }
    target_group_arn = aws_alb_target_group.clusters["cluster2"].arn
    target_id = aws_instance.small[each.value].id
}