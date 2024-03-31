locals {
  private_route_table_ids = module.vpc.private_route_table_ids
  public_route_table_ids  = module.vpc.public_route_table_ids
  private_subnets         = module.vpc.private_subnets
  vpc_cidr_block          = module.vpc.vpc_cidr_block
  vpc_id                  = module.vpc.vpc_id

  interface_endpoints = ["ecr.api", "sts", "ecr.dkr", "elasticloadbalancing", "ec2", "logs", "ecs", "kms"]
  gateway_endpoints  = ["s3"]

  endpoints = merge(
    {
      for service in local.interface_endpoints : service => {
        service    = service
        subnet_ids = local.private_subnets
        tags       = { Name = "${service}-vpc-endpoint" }
      }
    },
    {
      for service in local.gateway_endpoints : service => {
        service         = service
        route_table_ids = concat(local.public_route_table_ids, local.private_route_table_ids)
        tags            = { Name = "${service}-vpc-endpoint" }
      }
  })

}

resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "${var.app_name}-vpc-endpoint-sg"
  vpc_id = local.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }
}

module "endpoints" {
  source             = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  vpc_id             = local.vpc_id
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  endpoints          = local.endpoints
}