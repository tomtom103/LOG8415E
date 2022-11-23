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

    ami = "ami-0ee23bfc74a881de5"

    tags = {
        "Name": "Master"
    }
}

resource "null_resource" "aws_master_config" {
    triggers = {
        user_data = templatefile("${path.module}/../../scripts/configure_cluster_master.sh", {
            master_ip = aws_instance.master.private_ip,
            slave_one = aws_instance.slave[0].private_ip,
            slave_two = aws_instance.slave[1].private_ip,
            slave_three = aws_instance.slave[2].private_ip,
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
            "/bin/bash /tmp/user_data > /tmp/output.log",
            "/bin/bash -c \"timeout 300 sed '/finished-user-data/q' <(tail -f /tmp/output.log)\""
        ]
    }
}

# EC2 Instances
resource "aws_instance" "slave" {
    count = 3

    instance_type = "t2.micro"
    key_name = "vockey"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    ami = "ami-0ee23bfc74a881de5"

    tags = {
        "Name": "Slave-${count.index}"
    }
}

resource "null_resource" "aws_slave_config" {
    count = 3

    triggers = {
        user_data = templatefile("${path.module}/../../scripts/configure_cluster_slave.sh", {
            master_ip = aws_instance.master.private_ip,
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
            "/bin/bash /tmp/user_data > /tmp/output.log",
            "/bin/bash -c \"timeout 300 sed '/finished-user-data/q' <(tail -f /tmp/output.log)\""
        ]
    }

    depends_on = [
      null_resource.aws_master_config
    ]
}

output "master_public_dns" {
    description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
    value       = try(aws_instance.master.public_dns, "")
}