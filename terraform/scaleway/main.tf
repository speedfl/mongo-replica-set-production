provider "scaleway" {
  access_key      = var.access_key
  secret_key      = var.secret_key
  organization_id = var.organization_id
  zone            = var.zone
  region          = var.region
}

resource "scaleway_account_ssh_key" "main" {
  name       = "main"
  public_key = var.ssh_key
}

##################################################################################
#
# Public IPs
#
##################################################################################
resource "scaleway_instance_ip" "public_ip_mongo1" {}
resource "scaleway_instance_ip" "public_ip_mongo2" {}
resource "scaleway_instance_ip" "public_ip_mongo3" {}
resource "scaleway_instance_ip" "public_ip_mongo_arbiter" {}


locals {
  trusted_mongo = [
    scaleway_instance_ip.public_ip_mongo1.address,
    scaleway_instance_ip.public_ip_mongo2.address,
    scaleway_instance_ip.public_ip_mongo3.address,
    scaleway_instance_ip.public_ip_mongo_arbiter.address
  ]
}

##################################################################################
#
# Security group
#
##################################################################################
resource "scaleway_instance_security_group" "mongo" {
  name                    = "mongo_sg"
  description             = "The mongoDB security group"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  # allow all from Devops home
  inbound_rule {
    action = "accept"
    ip     = var.home_ip
  }

  # allow 80 for letsencrypt (will be handled with firewalld)
  inbound_rule {
    action = "accept"
    port   = "80"
  }

  # allow 443 for letsencrypt (will be handled with firewalld)
  inbound_rule {
    action = "accept"
    port   = "443"
  }

  # allow monitoring port from all members to all members
  dynamic "inbound_rule" {
    for_each = local.trusted_mongo

    content {
      action = "accept"
      port   = "42000"
      ip     = inbound_rule.value
    }
  }

  dynamic "inbound_rule" {
    for_each = local.trusted_mongo

    content {
      action = "accept"
      port   = "42001"
      ip     = inbound_rule.value
    }
  }

  dynamic "inbound_rule" {
    for_each = local.trusted_mongo

    content {
      action = "accept"
      port   = "42002"
      ip     = inbound_rule.value
    }
  }

  dynamic "inbound_rule" {
    for_each = local.trusted_mongo

    content {
      action = "accept"
      port   = "42003"
      ip     = inbound_rule.value
    }
  }

  dynamic "inbound_rule" {
    for_each = local.trusted_mongo

    content {
      action = "accept"
      port   = "42004"
      ip     = inbound_rule.value
    }
  }

  dynamic "inbound_rule" {
    for_each = local.trusted_mongo

    content {
      action = "accept"
      port   = "42005"
      ip     = inbound_rule.value
    }
  }

  # allow monitoring server port from all members to all members
  dynamic "inbound_rule" {
    for_each = local.trusted_mongo

    content {
      action = "accept"
      port   = "8443"
      ip     = inbound_rule.value
    }
  }

  # accept All 27017 from all mongo nodes
  dynamic "inbound_rule" {
    for_each = local.trusted_mongo

    content {
      action = "accept"
      port   = "27017"
      ip     = inbound_rule.value
    }
  }
}

##################################################################################
#
# Storage
#
##################################################################################
resource "scaleway_instance_volume" "data_mongo1" {
  name       = "mongo1-volume"
  size_in_gb = var.mongo_volume_size
  type       = "b_ssd"
}

resource "scaleway_instance_volume" "data_mongo2" {
  name       = "mongo2-volume"
  size_in_gb = var.mongo_volume_size
  type       = "b_ssd"
}

resource "scaleway_instance_volume" "data_mongo3" {
  name       = "mongo3-volume"
  size_in_gb = var.mongo_volume_size
  type       = "b_ssd"
}

resource "scaleway_instance_volume" "data_mongo_arbiter" {
  name       = "mongoarbiter-volume"
  size_in_gb = var.mongo_arbiter_volume_size
  type       = "b_ssd"
}

##################################################################################
#
# Instances
#
##################################################################################
resource "scaleway_instance_server" "mongo1" {
  name  = "mongo-1"
  type  = var.mongo_instance_type
  image = "ubuntu-bionic"

  tags = ["mongo", "mongo1"]

  ip_id = scaleway_instance_ip.public_ip_mongo1.id

  additional_volume_ids = [scaleway_instance_volume.data_mongo1.id]

  security_group_id = scaleway_instance_security_group.mongo.id
}

resource "scaleway_instance_server" "mongo2" {
  name  = "mongo-2"
  type  = var.mongo_instance_type
  image = "ubuntu-bionic"

  tags = ["mongo", "mongo2"]

  ip_id = scaleway_instance_ip.public_ip_mongo2.id

  additional_volume_ids = [scaleway_instance_volume.data_mongo2.id]

  security_group_id = scaleway_instance_security_group.mongo.id
}

resource "scaleway_instance_server" "mongo3" {
  name  = "mongo-3"
  type  = var.mongo_instance_type
  image = "ubuntu-bionic"

  tags = ["mongo", "mongo3"]

  ip_id = scaleway_instance_ip.public_ip_mongo3.id

  additional_volume_ids = [scaleway_instance_volume.data_mongo3.id]

  security_group_id = scaleway_instance_security_group.mongo.id
}

resource "scaleway_instance_server" "mongo_arbiter" {
  name  = "mongo-arbiter"
  type  = var.mongo_arbiter_instance_type
  image = "ubuntu-bionic"

  tags = ["mongo", "mongo_arbiter"]

  ip_id = scaleway_instance_ip.public_ip_mongo_arbiter.id

  additional_volume_ids = [scaleway_instance_volume.data_mongo_arbiter.id]

  security_group_id = scaleway_instance_security_group.mongo.id
}
