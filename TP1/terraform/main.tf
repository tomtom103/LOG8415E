provider "aws" {
    region = "${var.aws_region}"
    # access_key = "${var.aws_access_key}"
    # secret_key = "${var.aws_secret_key}"
}

# resource "aws_instance" "instance" {
#   ami                         = "${var.instance-ami}"
#   instance_type               = "${var.instance-type}"
 
#   iam_instance_profile        = "${var.iam-role-name != "" ? var.iam-role-name : ""}"
#   key_name                    = "${var.instance-key-name != "" ? var.instance-key-name : ""}"
#   associate_public_ip_address = "${var.instance-associate-public-ip}"
#   # user_data                   = "${file("${var.user-data-script}")}"
#   user_data                   = "${var.user-data-script != "" ? file("${var.user-data-script}") : ""}"
#   vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
#   subnet_id                   = "${aws_subnet.subnet.id}"

#   tags = {
#     Name = "${var.instance-tag-name}"
#   }
# }

# resource "aws_internet_gateway" "ig" {
#   vpc_id = "${aws_vpc.vpc.id}"

#   tags = {
#     Name = "${var.ig-tag-name}"
#   }
# }

resource "aws_security_group" "sg" {
  name   = "everywhere-2"
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

}