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

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for user in var.users :
    user.name => user
  }

  user   = each.key
  groups = each.value.is_developer ? [aws_iam_group.develop.name, aws_iam_group.employee.name] : [aws_iam_group.employee.name]
}

// developer인 user들만 필터링해서 locals에 저장
locals {
  developers = [
    for user in var.users :
    user
    if user.is_developer
  ]
}

// developer들에게 권한 부여
resource "aws_iam_user_policy_attachment" "developer" {
  for_each = {
    for user in local.developers :
    user.name => user
  }

  user       = each.key
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [
    aws_iam_user.this
  ]
}
