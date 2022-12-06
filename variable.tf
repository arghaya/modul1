variable "namespace" {
  type    = string
  default = "arghaya"
}

variable "stage" {
  type    = string
  default = "prod"
}

variable "name" {
  type    = string
  default = "module1"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "account_number" {
  type    = list(string)
  default = ["111559910807"]
}

