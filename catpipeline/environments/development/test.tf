resource "aws_instance" "test" {
  count = 0
  ami           = var.aws_ami_id
  instance_type = "t2.micro"
  iam_instance_profile = module.security.test_instance_profile_name
  subnet_id = module.network.catpipeline_subnet_primary_id
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install wget git -y
    sudo yum install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    id ec2-user
    newgrp docker
  EOF
  user_data_replace_on_change = true
  vpc_security_group_ids = [
    module.network.catpipeline_sg_id
  ]
  depends_on = [
     module.network
   ]
}