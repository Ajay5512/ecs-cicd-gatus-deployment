variable "execution_role_name" {
  type    = string
  default = "ecsTaskExecutionRole-gatus"
}


variable "execution_role_policy_arns" {
  type = set(string)
  default = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

