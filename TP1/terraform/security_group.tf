resource "aws_security_group" "everywhere" {
    name   = "everywhere"
    vpc_id = "${var.vpc_id}"

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