# Env
resource_name_prefix = "dxc-selenium"


vpc_cidr_block = "172.32.0.0/16"

bastion_subnets_cidr_list        = ["172.32.0.0/24", "172.32.1.0/24"]
private_egress_subnets_cidr_list = ["172.32.2.0/24", "172.32.3.0/24"]
