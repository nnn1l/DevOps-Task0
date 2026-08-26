variable "public_subnet_ids" { type = list(string) }
variable "ecs_tasks_security_group_id" { type = string }
variable "frontend_target_group_arn" { type = string }
variable "github_username" { type = string }
variable "ecr_image_url" { type = string }