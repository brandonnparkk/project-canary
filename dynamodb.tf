# dynamodb tables

resource "aws_dynamodb_table" "main" {
    name = "${local.name_prefix}-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"

    attribute {
        name = "id"
        type = "S"
    }

    tags = {
        Name = "${local.name_prefix}-table"
    }
}