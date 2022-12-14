output "master_public_ip" {
    description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
    value       = try(aws_instance.master.public_ip, "")
}

output "slave_public_ips" {
    description = "The public IP address assigned to all slave instances"
    value = "[${join(",", aws_instance.slave.*.public_ip)}]"
}
