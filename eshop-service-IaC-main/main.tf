
module "vpc" {
  source          = "./vpc_module"
  cluster_name    = var.cluster_name
}

module "sg" {
    source = "./sg_module"
    # should use count variable to use "*""
    vpc_id = module.vpc.vpc_id
    svc_name = "eshop"
    purpose = "t3"
    env = "svc"
    region_name_alias = "us"
    sg_rules = var.sg_rules
}

module "vpc_endpoints" {
    source = "./ep_module"
    vpc_id = module.vpc.vpc_id
    region_name = var.aws_region
    svc_name = "eshop"
    purpose = "t3"
    env = "svc"
    region_name_alias = "us"
    
    interface_endpoints = {
        # sns = {
        #     subnet_ids = module.vpc.privnat_subnet_ids
        #     security_groups = [module.sg.sg_id_map["endpoints"]]
        # }
        # logs = { # AWS cloudwatch logs vpc endpoint
        #     subnet_ids = module.vpc.privnat_subnet_ids
        #     security_groups = [module.sg.sg_id_map["endpoints"]]
        # }
        autoscaling = { # AWS autoscaling vpc endpoint AWS Console <----> EKS autoscaler controller
            subnet_ids = module.vpc.private_subnet_id
            security_groups = [module.sg.sg_id_map["endpoints"]]
        }
        # elasticloadbalancing = { # ELB vpc endpoint
        #     subnet_ids = module.vpc.private_subnet_id
        #     security_groups = [module.sg.sg_id_map["endpoints"]]
        # }
    }
}

module "eks" {

  #depends_on = [module.vpc]
  depends_on = [module.vpc_endpoints]
  
  source = "./eks_module"

  cluster_name      = var.cluster_name
  cluster_node_name = var.cluster_node_name
  node_type         = var.node_type
  node_desired_size = var.node_desired_size
  node_max_size     = var.node_max_size
  node_min_size     = var.node_min_size
  aws_region        = var.aws_region

  vpc_id     = module.vpc.vpc_id
  subnet_id1 = module.vpc.private_subnet_id[0]
  subnet_id2 = module.vpc.private_subnet_id[1]

  endpoint_private_access = true
  endpoint_public_access = true
  #EKS API Server로 MGMT VPC내 생성된 Nat Gateway의 IP를 ACL에 허용한다. (admin server => Service EKS Cluster 제어)
  public_access_cidrs = ["${var.mgmt_nat_gw_ip}/32"]
}
