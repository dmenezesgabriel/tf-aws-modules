variable "region" {
  description = "AWS region"
  type        = string
}

variable "ecr_repository_name" {
  description = "AWS ECR repository name"
  type        = string
}

variable "ecr_registry_uri" {
  description = "AWS ECR repository uri"
  type        = string
}

variable "container_image_tag" {
  description = "Container image tag"
  type        = string

}

variable "container_image_source_path" {
  description = "Container image source path"

}

variable "force_image_rebuild" {
  type    = bool
  default = false
}
