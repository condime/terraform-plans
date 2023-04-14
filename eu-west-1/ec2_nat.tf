# Cheap mode: NAT Instances are EC2 instances with some IP checks disabled
# Linux iptables performs POSTROUTING S-NAT if your bill is dominated by NAT GW hours
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html
module "nat_instance" {
  source = "../modules/ec2/instance"
  name   = "nat"
  count  = 1

  # Required for NAT to perform it's lies
  source_dest_check = false

  subnet_id             = element(module.public_subnets.subnet_ids, count.index)
  security_group_ids    = [aws_security_group.default.id]
  instance_profile_name = aws_iam_instance_profile.nat.name

  user_data = filebase64("${path.module}/user_data/nat.tpl")
}

resource "aws_iam_instance_profile" "nat" {
  name = "nat"
  role = aws_iam_role.nat.name
}

resource "aws_iam_role" "nat" {
  name               = "nat"
  description        = "EC2 Instance Role for NAT"
  assume_role_policy = data.aws_iam_policy_document.assume-ec2.json
}

resource "aws_iam_role_policy_attachment" "nat" {
  role       = aws_iam_role.nat.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "nat-config-reader" {
  role       = aws_iam_role.nat.id
  policy_arn = aws_iam_policy.config-reader.arn
}

resource "aws_iam_policy" "config-reader" {
  name   = "ConfigReader"
  policy = data.aws_iam_policy_document.config-reader.json
}

data "aws_iam_policy_document" "config-reader" {
  statement {
    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:eu-west-1:055237546114:secret:server.key-HyXG1o",
      "arn:aws:secretsmanager:eu-west-1:055237546114:secret:server.pem-1oLgLZ",
    ]
  }
}
