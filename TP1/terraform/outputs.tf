output "elb_id" {
    description = "ID of the ELB"
    value = module.elb.elb_id
}

output "elb_name" {
    description = "Name of the ELB"
    value = module.elb.elb_name
}

output "elb_dns_name" {
    description = "DNS name of the ELB"
    value = module.elb.elb_dns_name
}

output "elb_instances" {
    description = "The list of instances in the ELB (if may be outdated, because instances are attached using elb_attachment resource)"
    value = module.elb.elb_instances
}

output "elb_source_security_group_id" {
    description = "The ID of the security group that you can use as part of your inbound rules for your load balancer's back-end application instances"
    value = module.elb.elb_source_security_group_id
}

output "elb_zone_id" {
    description = "The canonical hosted zone ID of the ELB"
    value = module.elb.elb_zone_id
}