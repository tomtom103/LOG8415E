output "proxy_public_ip" {
    description = "The public IP address assigned to the proxy instance"
    value       = try(aws_instance.proxy.public_ip, "")
}