module "debug" {
  source = "../modules/ec2/instance"
  name   = "debug"
  count  = 0

  subnet_id             = element(module.private_subnets.subnet_ids, count.index)
  security_group_ids    = [aws_security_group.default.id]
  instance_profile_name = aws_iam_instance_profile.debug.name

  user_data = filebase64("${path.module}/user_data/debug.tpl")
}

resource "aws_iam_instance_profile" "debug" {
  name = "debug"
  role = aws_iam_role.debug.name
}

resource "aws_iam_role" "debug" {
  name               = "debug"
  description        = "EC2 Instance Role for Debugging"
  assume_role_policy = data.aws_iam_policy_document.assume-ec2.json
}

resource "aws_iam_role_policy_attachment" "debug" {
  role       = aws_iam_role.debug.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
