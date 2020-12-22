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

variable "region" {
    type = string
    default = "us-central1"
}

variable "zone" {
    type = string
    default = "us-central1c"
}
