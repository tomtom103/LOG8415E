# EC2 Instances
resource "aws_instance" "standalone" {
    instance_type = "t2.micro"
    key_name = "vockey"

    vpc_security_group_ids = [
        aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)
    user_data = "${file("${path.module}/external/user_data.sh")}"

    ami = "ami-0149b2da6ceec4bb0"

    tags = {
        "Name": "Standalone"
    }

    # Connection settings used by the provisioner
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("../../labsuser.pem")
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