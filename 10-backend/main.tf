// Remote Backend를 S3로 관리
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "terraform-example-brian"

    workspaces {
      name = "practice-tf-backend"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

// IAM Groups
resource "aws_iam_group" "develop" {
  name = "developer"
}

resource "aws_iam_group" "employee" {
  name = "employee"
}

output "groups" {
  value = [
    aws_iam_group.develop,
    aws_iam_group.employee
  ]
}

// Users
variable "users" {
  type = list(any)
}

// IAM User를 for_each를 통해 정의
resource "aws_iam_user" "this" {
  for_each = {
    for user in var.users :
    user.name => user
  }

  name = each.key

  tags = {
    level = each.value.level
    role  = each.value.role
  }
}
