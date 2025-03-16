data "aws_ami" "amzn-linx" {

	most_recent = true
	owners = ["amazon"]

        filter {
                name   = "name"
                values = ["amzn2-ami-hvm*"]
        }

        filter {
                name = "root-device-type"
                values = ["ebs"]
        }

        filter {
                name = "virtualization-type"
                values = ["hvm"]
        }
}



resource "aws_iam_instance_profile" "role_profile" {
  name = "SSMFullAccess"
  role = aws_iam_role.ssm_access.name
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amzn-linx.id
  instance_type = var.instancetype
  count = 1
  iam_instance_profile = aws_iam_instance_profile.role_profile.name
  subnet_id = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true 
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = element(var.ec2_names, 0)
  }
  depends_on = [ aws_iam_role.ssm_access, aws_iam_policy_attachment.attachment,  ]
}
