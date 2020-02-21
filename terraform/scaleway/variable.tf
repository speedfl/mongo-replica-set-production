#--------------------------------------------------------------
# General
#--------------------------------------------------------------
variable "access_key" {
  description = "The access key to interact with API"
  default     = "<your_access_key>"
}

variable "secret_key" {
  description = "The secret key to interact with API"
  default     = "<your_secret_key>"
}

variable "organization_id" {
  description = "The Organization"
  default     = "<your_organization>"
}

variable "region" {
  description = "The Scaleway region"
  default     = "fr-par"
}

variable "zone" {
  description = "The Scaleway Zone"
  default     = "fr-par-1"
}

variable "ssh_key" {
  description = "db_key.pub"
  default     = "ssh-rsa your_public_key_goes_here"
}

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------
variable "home_ip" {
  description = "The Devops home IP."
  default     = "<your_home_ip>"
}

#--------------------------------------------------------------
# Instances
#--------------------------------------------------------------
variable "mongo_instance_type" {
  description = "Type of instance to use for mongodb nodes"
  default     = "DEV1-M"
}

variable "mongo_arbiter_instance_type" {
  description = "Type of instance to use for mongodb arbiter node"
  default     = "DEV1-M"
}

variable "mongo_volume_size" {
  description = "Size in GB of the mongodb volume"
  default     = 30
}

variable "mongo_arbiter_volume_size" {
  description = "Size in GB of the mongodb volume for arbiter"
  default     = 30
}