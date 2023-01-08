module "lambda" {
  source                                  = "terraform-aws-modules/lambda/aws"
  version                                 = "~> 2.0"
  create_role                             = false
  lambda_role                             = aws_iam_role.lambda_role.arn
  function_name                           = "start_stop"
  handler                                 = "start_stop.lambda_handler"
  runtime                                 = "python3.9"
  create_package                          = false
  local_existing_package                  = data.archive_file.lambda_zip.output_path
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    Start = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["cron_start"]
    },
    Stop = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["cron_stop"]
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "start_stop.zip"
  source {
    filename = "start_stop.py"
    content = templatefile("start_stop.py.tpl", {
      workstations_ids = join(",", ([for i in aws_instance.workstation[*].id : i]))
      region           = var.aws_region
      }
    )
  }
  depends_on = [aws_instance.workstation]
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Start*",
        "ec2:Stop*",
        "ec2:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "lambda"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}
