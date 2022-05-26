
module "cognito_pre_signup" {
  # https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
  source = "terraform-aws-modules/lambda/aws"

  function_name = "SUPER_FUNCTION_NAME"
  description   = "Cognito Pre Signup Lambda"
  publish       = true

  runtime = "go1.x"
  handler = "pre_signup"
  source_path = [
    {
      path = "${path.module}/../pre_signup",
      commands = [
        "go build -o bin/pre_signup",
        ":zip bin/pre_signup .",
      ]
    }
  ]

  // Environment Variables
  environment_variables = {
    ENV1 = "HOME"
  }

  // Permissions
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
  create_current_version_allowed_triggers = false
  allowed_triggers = {
    CognitoPermission = {
      action     = "lambda:InvokeFunction"
      principal  = "cognito-idp.amazonaws.com"
      source_arn = aws_cognito_user_pool.localstack_bug.arn
    }
  }

  // VPC
  vpc_subnet_ids         = ["private Subnet"]
  vpc_security_group_ids = ["private security group ids"]
  attach_network_policy  = true
}


resource "aws_cognito_user_pool" "localstack_bug" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool
  name = "local_stack_bug_report"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  username_configuration {
    // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool#username_configuration
    case_sensitive = false
  }

  password_policy {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool#password_policy
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  verification_message_template {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool#verification_message_template
    default_email_option = "CONFIRM_WITH_CODE"
  }

  device_configuration {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool#device_configuration
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = false
  }

  account_recovery_setting {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool#account_recovery_setting
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  lambda_config {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool#lambda_config
    pre_sign_up = module.cognito_pre_signup.lambda_function_arn
    # post_confirmation    = module.cognito_post_confirmation.lambda_function_arn
    # pre_token_generation = module.cognito_pre_token_generation.lambda_function_arn
    # custom_message       = module.cognito_custom_message.lambda_function_arn
    # TODO LOCALSTACK, you may want to check that validation_Data and client_metadata is also passed to the assosiated lambda methods
  }
}

resource "aws_cognito_user" "dev" {
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user#client_metadata

  user_pool_id = aws_cognito_user_pool.localstack_bug.id

  validation_data = {
    givenName  = "SUPER_GIVEN_NAME_VALIDATION"
    familyName = "SUPER_FAMILY_NAME_VALIDATION"
  }

  client_metadata = {
    givenName  = "SUPER_GIVEN_NAME_CLIENT_META_DATA"
    familyName = "SUPER_FAMILY_NAME_META_DATA"
  }

  username = "SuperUserName@home.com"
  password = "MadeInIreland"

  attributes = {
    // https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-attributes.html
    email          = "SuperEmail@SuperHost.com"
    email_verified = true
  }
}
