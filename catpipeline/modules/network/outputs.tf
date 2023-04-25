output "catpipeline_vpc_id" {
  description = "VPC Id of Catpipeline Lab"
  value = aws_vpc.catpipeline.id
}

output "catpipeline_sg_id" {
  description = "Sg name of Test"
  value = aws_security_group.allow_ssh.id
}

output "catpipeline_subnet_primary_id" {
  description = "Subnet id of primary"
  value = aws_subnet.catpipeline_primary.id
}

output "catpipeline_subnet_secondary_id" {
  description = "Subnet id of secondary"
  value = aws_subnet.catpipeline_secondary.id
}