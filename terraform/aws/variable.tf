#--------------------------------------------------------------
# General
#--------------------------------------------------------------
variable "region" {
  description = "The AWS region to create things in."
  default     = "eu-west-3"
}

variable "public_key_path" {
  description = "The path of the public key file to use"
  default     = "/path/to/ssl_key.pub"
}

variable "ami" {
  description = "The AMI to use. Be Carreful. Only Ubuntu 18.04 has been tested"
  default = "ami-096b8af6e7e8fb927"
}

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------
variable "home_ip" {
  description = "The Devops home IP."
  default     = "<your_ip>"
}

#--------------------------------------------------------------
# Instances
#--------------------------------------------------------------
variable "mongo_instance_type" {
  description = "Type of instance to use for mongodb nodes"
  default     = "t3a.medium"
}

variable "mongo_arbiter_instance_type" {
  description = "Type of instance to use for mongodb arbiter node"
  default     = "t3a.medium"
}

variable "mongo_volume_size" {
  description = "Size in GB of the mongodb volume"
  default     = 30
}

variable "mongo_arbiter_volume_size" {
  description = "Size in GB of the mongodb volume for arbiter"
  default     = 30
}

variable "encrypt_mongo_volume" {
  description = "Define whereas the mongodb volume needs to be encrypted. If true ansible deployment can skip 'encrypt-rest' plays"
  default      = false
}