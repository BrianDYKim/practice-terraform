provider "aws" {
  region = "ap-northeast-2"
}

# conditional expression
# Condition ? if_true_expression : if_false_expression
variable "is_john" {
  type    = bool
  default = true
}

locals {
  message = var.is_john ? "Hello John!" : "Hello!"
}

output "message" {
  value = local.message
}

# conditional generate resource trick by using count
variable "internet_gateway_enabled" {
  type    = bool
  default = true
}

resource "aws_vpc" "this" {
  cidr_block = "20.0.0.0/16"

  tags = {
    Name = "terraform-loop-example"
  }
}

resource "aws_internet_gateway" "this" {
  count = var.internet_gateway_enabled ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-igw"
  }
}
