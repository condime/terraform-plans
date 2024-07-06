# Cheap mode: NAT Instances are EC2 instances with some IP checks disabled
# Linux iptables performs POSTROUTING S-NAT if your bill is dominated by NAT GW hours
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html

# Note: If this resource changes, you must also update the TRUSTED_PROXY_IP variable
# https://consul.condi.me/ui/dc1/kv/condime/terraform_state/mastodon/trusted_proxy_ip/edit
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

# Cloudflare Origin secrets
# Download server.key and server.pem from the cloudflare dashboard
# https://dash.cloudflare.com/150b67ab2957ed2c7daab47f3140e529/nfra.club/ssl-tls/origin
#
# $ aws secretsmanager put-secret-value \
#    --secret-id arn:aws:secretsmanager:eu-west-1:055237546114:secret:server.key-HyXG1o \
#    --secret-string file://server.key
#
# $ aws secretsmanager put-secret-value \
#    --secret-id arn:aws:secretsmanager:eu-west-1:055237546114:secret:server.pem-1oLgLZ \
#    --secret-string file://server.pem
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
