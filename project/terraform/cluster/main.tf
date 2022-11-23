terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~>4.0"
      }
    }
}

provider "aws" {
    region = "us-east-1"
}

data "aws_vpc" "default" {
    default = true
}

# Existing subnet
data "aws_subnets" "all" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

# Security group that allows all incoming connections
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
}


# EC2 Instances
resource "aws_instance" "master" {
    instance_type = "t2.micro"
    key_name = "vockey"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    ami = "ami-0149b2da6ceec4bb0"

    tags = {
        "Name": "Master"
    }
}

resource "null_resource" "aws_master_config" {
    triggers = {
        user_data = templatefile("${path.module}/../../scripts/configure_cluster_master.sh", {
            master_ip = aws_instance.master.private_ip,
            slave_ips = jsonencode(aws_instance.slave[*].private_ip),
        })
    }

    provisioner "file" {
        content = self.triggers.user_data
        destination = "/tmp/user_data"
        connection {
            type = "ssh"
            user = "ubuntu"
            private_key = file("../../labsuser.pem")
            host = aws_instance.master.public_ip
        }
    }

    # Connection settings used by the provisioner
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("../../labsuser.pem")
        host = aws_instance.master.public_ip
    }

    # Allows us to make sure user_data script of EC2 instance has finished running
    # This provisioner also allows us to see the output log without having to connect to the instance
    provisioner "remote-exec" {
        inline = [
            "/bin/bash /tmp/user_data",
            "/bin/bash -c \"timeout 300 sed '/finished-user-data/q' <(tail -f /home/shared/output.log)\""
        ]
    }
}

# EC2 Instances
resource "aws_instance" "slave" {
    count = 2

    instance_type = "t2.micro"
    key_name = "vockey"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    ami = "ami-0149b2da6ceec4bb0"

    tags = {
        "Name": "Slave-${count.index}"
    }
}

resource "null_resource" "aws_slave_config" {
    count = length(aws_instance.slave)

    triggers = {
        user_data = templatefile("${path.module}/../../scripts/configure_cluster_slave.sh", {
            master_ip = aws_instance.master.private_ip,
            slave_ips = jsonencode(aws_instance.slave[*].private_ip),
        })
    }

    provisioner "file" {
        content = self.triggers.user_data
        destination = "/tmp/user_data"
        connection {
            type = "ssh"
            user = "ubuntu"
            private_key = file("../../labsuser.pem")
            host = aws_instance.slave[count.index].public_ip
        }
    }

    # Connection settings used by the provisioner
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("../../labsuser.pem")
        host = aws_instance.slave[count.index].public_ip
    }

    # Allows us to make sure user_data script of EC2 instance has finished running
    # This provisioner also allows us to see the output log without having to connect to the instance
    provisioner "remote-exec" {
        inline = [
            "/bin/bash /tmp/user_data",
            "/bin/bash -c \"timeout 300 sed '/finished-user-data/q' <(tail -f /home/shared/output.log)\""
        ]
    }
}
