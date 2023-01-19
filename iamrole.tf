
#Get provider configuration from terraform registry
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
  }
}

provider "aws" {
  profile = "AB"
  region  = "us-east-1"
}

#variable declararations for ami and keypair
variable "ami-Virginia" {
  type    = string
  default = "ami-0b5eea76982371e91"
}

variable "key-name" {
  type    = string
  default = "Abkeypair"
}


#create iam policy
resource "aws_iam_policy" "ec2-policy" {
  name        = "Ab-ec2-policy"
  path        = "/"
  description = "this policy is to give permission to access ec2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:Modify*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#create iam role
resource "aws_iam_role" "techchak_role" {
  name = "Ab_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


#attach policy to iam role 
resource "aws_iam_policy_attachment" "techchak_attachment" {
  name       = "ab_techchak_attachment"
  roles      = [aws_iam_role.techchak_role.name]
  policy_arn = aws_iam_policy.ec2-policy.arn
}


#create an instance profile using the role created above
resource "aws_iam_instance_profile" "techchak_profile" {
  name = "ab_techchak_profile"
  role = aws_iam_role.techchak_role.name
}

#attach instance profie to ec2
resource "aws_instance" "techchak_instance" {
  ami                  = var.ami-Virginia
  instance_type        = "t2.micro"
  key_name             = var.key-name
  iam_instance_profile = aws_iam_instance_profile.techchak_profile.name
}

output "public_ip" {
  value = aws_instance.techchak_instance.public_ip
}
