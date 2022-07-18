variable name {
  type        = string
  description = "description"
}

variable instance_type {
  type        = string
  default     = "t3.micro"
  description = "description"
}

variable docker_image {
  type        = string
  description = "description"
}


variable target_group_arn {
  type        = string
  description = "description"
}


variable key_name {
  type        = string
  description = "description"
}

variable security_group_ids {
  type        = list(string)
  default     = []
  description = "description"
}

variable "min_size" {
  type = string
  default = "1"
}

variable "max_size" {
  type = string
  default = "3"
}

variable "desired_capacity" {
  type = string
  default = "1"
}

