
output "ecr_repo_url" {
  value = aws_ecr_repository.flask_repo.repository_url
}
output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}