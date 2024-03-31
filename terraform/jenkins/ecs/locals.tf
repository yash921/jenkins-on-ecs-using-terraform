locals {
  vpc_id                 = data.aws_vpc.vpc.id
  private_subnet_ids     = data.aws_subnets.private_subnets.ids
  public_subnet_ids      = data.aws_subnets.public_subnets.ids
  jenkins_container_port = 8080
  private_subnets        = [for s in data.aws_subnet.private_subnets : s]
}
  