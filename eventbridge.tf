module "eventbridge" {
  source     = "terraform-aws-modules/eventbridge/aws"
  create_bus = false
  rules = {
    cron_start = {
      description         = "Trigger for a Lambda"
      schedule_expression = "cron(${var.start_m} ${var.start_h} ? * 2-6 *)"
    },
    cron_stop = {
      description         = "Trigger for a Lambda"
      schedule_expression = "cron(${var.stop_m} ${var.stop_h} ? * 2-6 *)"
    }
  }

  targets = {
    cron_start = [
      {
        name = "Trigger start_stop function"
        arn  = module.lambda.lambda_function_arn
      }
    ],
    cron_stop = [
      {
        name = "Trigger start_stop funcction"
        arn  = module.lambda.lambda_function_arn
      }
    ]
  }
}
