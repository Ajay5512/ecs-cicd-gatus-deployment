variable "ecr_image" {
  type    = string
  default = "112136120738.dkr.ecr.eu-west-2.amazonaws.com/gatus:latest"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}
