variable "aws_region" {
  description = "AWS region for infrastructure placing"
  type        = string
  default     = "eu-central-1"
}

variable "number" {
  description = "Number of workstations"
  type        = number
  default     = 3
}

variable "most_recent" {
  description = "Do you want the latest ami?"
  type        = bool
  default     = true
}

variable "owners" {
  description = "The ami´s owners"
  type        = list(string)
  default     = ["099720109477"]
}

variable "name_filter" {
  description = "Name filter for ami selection"
  type        = list(string)
  default     = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}

variable "virtualization_type" {
  description = "Virtualization-type filter for ami selection"
  type        = list(string)
  default     = ["hvm"]
}

variable "key_name" {
  description = "AWS key pair name?"
  type        = string
  default     = "ssh_key"
}

variable "public_key" {
  description = "AWS public ssh key path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "sg_name" {
  description = "AWS security group name"
  type        = string
  default     = "workstations-sg"
}

variable "open_ports" {
  description = "List of ports to open"
  type        = list(string)
  default     = ["22"]
}

variable "sg_protocol" {
  description = "SG protocol"
  type        = string
  default     = "tcp"
}

variable "all_addresses" {
  description = "Al IP addresses"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "AWS instance_type"
  type        = string
  default     = "t3.micro"
}

variable "common_tags" {
  description = "Infrastructure common tags"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Scheduled   = "true"
  }
}

variable "start_h" {
  type    = number
  default = 8
}
variable "start_m" {
  type    = number
  default = 0
}

variable "stop_h" {
  type    = number
  default = 17
}

variable "stop_m" {
  type    = number
  default = 0
}
