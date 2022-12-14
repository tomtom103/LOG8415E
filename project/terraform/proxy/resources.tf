# Load environment variables from .env file
locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("../../.env")) : tuple[0] => tuple[1] }
}

# Instance hosting the proxy pattern
resource "aws_instance" "proxy" {
    instance_type = "t2.micro"
    key_name = "vockey"

    vpc_security_group_ids = [
        data.aws_security_group.everywhere.id,
    ]
    subnet_id = element(tolist(data.aws_subnets.all.ids), 0)

    user_data = templatefile("${path.module}/external/user_data_proxy.sh.tftpl", {
        docker_image_name = local.envs["DOCKER_IMAGE_NAME"],
    })

    ami = "ami-0ee23bfc74a881de5"

    tags = {
        "Name": "Proxy"
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