variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "https_protocol" {
  type = string
  default = "443"
}

variable "instance_cout" {
  description = "list users"
  type = list
  default = ["dev", "prod"]
}