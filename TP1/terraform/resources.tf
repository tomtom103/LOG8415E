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

## Security Group
resource "aws_security_group" "everywhere" {
    name   = "everywhere"
    vpc_id = "${data.aws_vpc.default.id}"

    ingress {
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 0
        to_port     = 0
    }
    egress {
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 0
        to_port     = 0
    }

    tags = var.common_tags
}

## ALB
resource "aws_lb_target_group" "cluster1" {
    name        = "cluster1"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = data.aws_vpc.default.id
}

resource "aws_lb_target_group" "cluster2" {
    name        = "cluster2"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = data.aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "att-cluster1" {
    count = length(aws_instance.m4)
    target_group_arn = aws_lb_target_group.cluster1.arn
    target_id = aws_instance.m4[count.index].id
    port = 80
}

resource "aws_lb_target_group_attachment" "att-cluster2" {
    count = length(aws_instance.t2)
    target_group_arn = aws_lb_target_group.cluster2.arn
    target_id = aws_instance.t2[count.index].id
    port = 80
}

resource "aws_lb" "alb" {
    name            = "alb"
    internal        = false
    ip_address_type = "ipv4"
    load_balancer_type = "application"
    security_groups = [aws_security_group.everywhere.id]
    # Subnets used by EC2 instances
    subnets         = [
        element(tolist(data.aws_subnets.all.ids), 0),
        element(tolist(data.aws_subnets.all.ids), 1),
    ]

    access_logs {
        bucket  = aws_s3_bucket.alb_logs.bucket
        enabled = true
    }

    tags = var.common_tags
}

resource "aws_lb_listener" "alb_listener_http" {
    load_balancer_arn = aws_lb.alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "Do not call this endpoint directly..."
            status_code  = "404"
        }
    }
}

resource "aws_lb_listener_rule" "rule_cluster1" {
    listener_arn = aws_lb_listener.alb_listener_http.arn
    priority     = 101

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.cluster1.arn
    }

    condition {
        path_pattern {
            values = ["/cluster1"]
        }
    }
}

resource "aws_lb_listener_rule" "rule_cluster2" {
    listener_arn = aws_lb_listener.alb_listener_http.arn
    priority     = 100

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.cluster2.arn
    }

    condition {
        path_pattern {
            values = ["/cluster2"]
        }
    }
}