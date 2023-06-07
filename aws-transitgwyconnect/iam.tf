/*
resource "aws_iam_role" "fgt" {
  name = "fgt"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "ec2:Describe*",
            "ec2:AssociateAddress",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses",
            "ec2:ReplaceRoute"
            ],
        "Resource": "*",
        "Effect": "Allow"
        }
    ]
  })
}


*/