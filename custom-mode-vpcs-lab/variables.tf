variable "uid_prefix" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "services" {
    type = list
    default = ["compute.googleapis.com"]
}

variable "lab_name" {
  type    = string
  default = "custom-mode-vpcs-lab"
}
