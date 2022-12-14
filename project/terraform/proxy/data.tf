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

# Existing security group created by the cluster deployment
data "aws_security_group" "everywhere" {
    name = "everywhere"
}
