output "elb_id" {
    description = "ID of the ELB"
    value = aws_lb.elb.id
}

output "elb_name" {
    description = "Name of the ELB"
    value = aws_lb.elb.name
}

output "elb_dns_name" {
    description = "DNS name of the ELB"
    value = aws_lb.elb.dns_name
}

output "elb_zone_id" {
    description = "The canonical hosted zone ID of the ELB"
    value = aws_lb.elb.zone_id
}