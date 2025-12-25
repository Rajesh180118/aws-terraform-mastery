#Used for creating IAM users
resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }
  name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
  path = "/users/"

  tags = {
    "department" = each.value.department
  }
}

#Used for creating password and allow console access
resource "aws_iam_user_login_profile" "example" {
  for_each = aws_iam_user.users
  user                    = each.value.name
  # pgp_key                 = "keybase:rajesh1801"
  password_reset_required = true

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
    ]
  }
}

#Used for creating IAM groups
resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups/"
}

resource "aws_iam_group" "corporate" {
  name = "Corporate"
  path = "/groups/"
}

resource "aws_iam_group" "accounting" {
  name = "Accounting"
  path = "/groups/"
}

#Used for creating IAM group memberships for adding users to groups
resource "aws_iam_group_membership" "Education" {
  name = "Adding education"
  users = [
    for user in aws_iam_user.users : user.name if user.tags.department == "Education"
  ]
  group = aws_iam_group.education.name
}

resource "aws_iam_group_membership" "Corporate" {
  name = "Adding corporate"
  users = [
    for user in aws_iam_user.users : user.name if user.tags.department == "Corporate"
  ]
  group = aws_iam_group.corporate.name
}

resource "aws_iam_group_membership" "Accounting" {
  name = "Adding accounting"
  users = [
    for user in aws_iam_user.users : user.name if user.tags.department == "Accounting"
  ]
  group = aws_iam_group.accounting.name
}


# resource "aws_iam_policy" "require_mfa" {
#   name = "require-mfa"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "AllowUsersToManageOwnMFA",
#         Effect = "Allow",
#         Action = [
#           "iam:CreateVirtualMFADevice",
#           "iam:EnableMFADevice",
#           "iam:GetUser",
#           "iam:ListMFADevices",
#           "iam:ListVirtualMFADevices",
#           "iam:ResyncMFADevice"
#         ],
#         Resource = "*"
#       },
#       {
#         Sid    = "DenyAllExceptIAMIfNoMFA",
#         Effect = "Deny",
#         NotAction = [
#           "iam:CreateVirtualMFADevice",
#           "iam:EnableMFADevice",
#           "iam:GetUser",
#           "iam:ListMFADevices",
#           "iam:ListVirtualMFADevices",
#           "iam:ResyncMFADevice",
#           "iam:ChangePassword"
#         ],
#         Resource = "*",
#         Condition = {
#           BoolIfExists = {
#             "aws:MultiFactorAuthPresent" = "false"
#           }
#         }
#       }
#     ]
#   })
# }

# #
# resource "aws_iam_group_policy_attachment" "Education-RequireMFA" {
#   group      = aws_iam_group.education.name
#   policy_arn = aws_iam_policy.require_mfa.arn
# }








# output "name" {
#   value = [for user in aws_iam_user.users : user.name]
# }
output "user_passwords" {
 #It is a map that's why we are using for user, profile which means for key, value 
  value = {
    for user, profile in aws_iam_user_login_profile.example :
    user => "Password created - user must reset on first login"
  }
  sensitive = true
}

# Attach ReadOnly policy to Education group
resource "aws_iam_group_policy_attachment" "Education-ReadOnly" {
  group      = aws_iam_group.education.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# resource "aws_iam_group_policy_attachment" "Corporate-ReadOnly" {
#   group      = aws_iam_group.corporate.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
# }

# resource "aws_iam_group_policy_attachment" "Accounting-ReadOnly" {
#   group      = aws_iam_group.accounting.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
# }

# output "user_passwords_encrypted" {
#   value = {
#     for user, profile in aws_iam_user_login_profile.example :
#     user => profile.encrypted_password
#   }
#   sensitive = true
# }

# Output key fingerprint for verification
# output "key_fingerprint" {
#   value = aws_iam_user_login_profile.example["Michael"].key_fingerprint
# }

output "education_user" {
  value = [for user in aws_iam_user.users : user.name if user.tags.department == "Education"]
}



output "arn" {
  # value = tolist(data.aws_ssoadmin_instances.example.arns)[0]
  value = data.aws_ssoadmin_instances.example.arns
}

output "identity_store_id" {
  value = data.aws_ssoadmin_instances.example.identity_store_ids
}

resource "aws_identitystore_user" "example" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
  for_each = { for user in local.users : lower("${substr(user.first_name, 0, 1)}${user.last_name}") => user if user.department == "Education" }
  display_name = "${each.value.first_name} ${each.value.last_name}"
  user_name    = each.key

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  emails {
    value = "${each.value.first_name}.${each.value.last_name}@example.com"
  }
}

resource "aws_identitystore_group" "education_group" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
  display_name = "Education Group"
}

resource "aws_identitystore_group_membership" "name" {
  for_each = aws_identitystore_user.example
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
  group_id          = aws_identitystore_group.education_group.group_id
  member_id         = each.value.user_id

}

resource "aws_ssoadmin_permission_set" "permission_set" {
  name               = "Education-Permission-Set"
  description        = "Permission set for Education users"
  session_duration   = "PT1H"
  instance_arn       = tolist(data.aws_ssoadmin_instances.example.arns)[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "permission_set_attachment" {
  instance_arn     = tolist(data.aws_ssoadmin_instances.example.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_set.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" 
}

resource "aws_ssoadmin_account_assignment" "attaching_permission_to_group" {
  instance_arn     = tolist(data.aws_ssoadmin_instances.example.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_set.arn
  principal_id      = aws_identitystore_group.education_group.group_id
  principal_type    = "GROUP"
  target_id         = data.aws_caller_identity.current.account_id
  target_type       = "AWS_ACCOUNT"
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
  
}

output "name" {
  value = [for user in aws_identitystore_user.example : user.user_id]
}
