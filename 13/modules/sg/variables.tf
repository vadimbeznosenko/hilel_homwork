variable "https_protocol" {
  type = string
  default = "443"
}

variable "name" {
  type = string
}

variable "instance_name" {
  type = string
  default = "example-ec2"
}

variable "alb_name" {
  type = string
  default = "example-alb"
}