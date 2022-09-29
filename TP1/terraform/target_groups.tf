resource "aws_lb_target_group" "cluster1" {
    name = "cluster1"
    port = 80
    protocol = "HTTP"
    vpc_id = "${var.vpc_id}"
}

resource "aws_lb_target_group" "cluster2" {
    name = "cluster2"
    port = 80
    protocol = "HTTP"
    vpc_id = "${var.vpc_id}"
}


module "aws_elb_attachment_large" {
  source  = "terraform-aws-modules/elb/aws//modules/elb_attachment"
  version = "3.0.1"
  
  elb = "${module.elb.elb_id}"
  instances = aws_instance.large.*.id
  number_of_instances = var.number_of_instances
}

module "aws_elb_attachment_small" {
  source  = "terraform-aws-modules/elb/aws//modules/elb_attachment"
  version = "3.0.1"
  
  elb = "${module.elb.elb_id}"
  instances = aws_instance.small.*.id
  number_of_instances = var.number_of_instances
}
