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
resource "aws_iam_group" "this" {
  for_each =toset(["develop", "employee"])

  name = each.key
}

output "groups" {
  value = aws_iam_group.this
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

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for user in var.users :
    user.name => user
  }

  user   = each.key
  groups = each.value.is_developer ? [aws_iam_group.this["develop"].name, aws_iam_group.this["employee"].name] : [aws_iam_group.this["employee"].name]
}

// developer인 user들만 필터링해서 locals에 저장
locals {
  developers = [
    for user in var.users :
    user
    if user.is_developer
  ]
}


