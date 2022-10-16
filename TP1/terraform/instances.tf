## EC2 Instances
resource "aws_instance" "m4" {
    count = 5
    instance_type = "${var.m4_instance_type}"

    key_name = "${var.key_name}"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    user_data = templatefile("${path.module}/../scripts/startup.sh", {
        instance_name = "${random_pet.this.id}-m4-${count.index}"
    })

    ami = "ami-08c40ec9ead489470"
    tags = {
        "Name" = "${random_pet.this.id}-m4-${count.index}"
        "Application" = "TP1"
        "Version" = "latest"
    }
}

resource "aws_instance" "t2" {
    count = 4

    instance_type = "${var.t2_instance_type}"
    key_name = "${var.key_name}"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 1)

    user_data = templatefile("${path.module}/../scripts/startup.sh", {
        instance_name = "${random_pet.this.id}-t2-${count.index}"
    })

    ami = "ami-08c40ec9ead489470"
    tags = {
        "Name" = "${random_pet.this.id}-t2-${count.index}"
        "Application" = "TP1"
        "Version" = "latest"
    }
}