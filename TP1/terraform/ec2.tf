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