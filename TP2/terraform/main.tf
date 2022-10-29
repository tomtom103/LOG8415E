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

# Existing vpc
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

# m4.large EC2 instance
resource "aws_instance" "m4" {
    instance_type = "m4.large"
    key_name = "vockey"

    # Id of previously created security group
    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)
    user_data = "${file("${path.module}/../scripts/configure_instance.sh")}"
    ami = "ami-08c40ec9ead489470"

    tags = {
        "Name": "TP2 Instance"
    }

    # Connection settings used by the provisioner
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("../labuser.pem")
        host = self.public_ip
    }

    # Allows us to make sure user_data script of EC2 instance has finished running
    # This provisioner also allows us to see the output log without having to connect to the instance
    provisioner "remote-exec" {
        inline = [
            "/bin/bash -c \"timeout 300 sed '/finished-user-data/q' <(tail -f /var/log/cloud-init-output.log)\""
        ]
    }
}

# Prints the public DNS address to avoid having to open the AWS UI to fetch it
output "public_dns" {
    description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
    value       = try(aws_instance.m4.public_dns, "")
}