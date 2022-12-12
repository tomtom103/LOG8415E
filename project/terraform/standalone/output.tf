output "public_dns" {
    description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
    value       = try(aws_instance.standalone.public_dns, "")
}
