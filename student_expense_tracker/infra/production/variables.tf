variable "mongodb_uri" {
  description = "MongoDB Atlas URI"
  type        = string
}

variable "github_repo_url" {
  description = "GitHub repository to deploy from"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to deploy"
  type        = string
  default     = "main"
}


variable "location" {
  description = "Azure region"
  type        = string
  default     = "uaenorth"
}

variable "image_name" {
  default = "stucents-app1"
}
variable "image_tag" {
  default = "production"
}