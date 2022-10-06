output "elb_id" {
    description = "ID of the ELB"
    value = aws_alb.alb.id
}

output "elb_name" {
    description = "Name of the ELB"
    value = aws_alb.alb.name
}

output "elb_dns_name" {
    description = "DNS name of the ELB"
    value = aws_alb.alb.dns_name
}

output "elb_zone_id" {
    description = "The canonical hosted zone ID of the ELB"
    value = aws_alb.alb.zone_id
}