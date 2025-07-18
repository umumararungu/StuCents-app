variable "resource_group_name" {
  default = "stucentsexpenses-rg"
}

variable "location" {
  default = "WEST US"
}

variable "acr_name" {
  default = "stucentsacr"
}

variable "mongo_uri" {
  description = "Your hosted MongoDB URI"
  type        = string
}
