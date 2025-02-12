resource "rancher2_cluster" "fleet_0" {
  name = "${var.prefix}-fleet-0"
  labels = {
    cpu      = "amd"
    location = "central"
    distro   = "k3s"
  }
}
resource "rancher2_cluster" "fleet_1" {
  name = "${var.prefix}-fleet-1"
  labels = {
    cpu      = "amd"
    location = "west"
    distro   = "k3s"
  }
}
resource "rancher2_cluster" "fleet_2" {
  name = "${var.prefix}-fleet-2"
  labels = {
    cpu      = "arm"
    location = "central"
    distro   = "k3s"
  }
}

resource "null_resource" "registration_0" {
  depends_on = [
    null_resource.k3s_0,
  ]
  provisioner "local-exec" {
    command = rancher2_cluster.fleet_0.cluster_registration_token[0].command
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig_0"
    }
  }
}
resource "null_resource" "registration_1" {
  depends_on = [
    null_resource.k3s_1,
  ]
  provisioner "local-exec" {
    command = rancher2_cluster.fleet_1.cluster_registration_token[0].command
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig_1"
    }
  }
}
resource "null_resource" "registration_2" {
  depends_on = [
    null_resource.k3s_2,
  ]
  provisioner "local-exec" {
    command = rancher2_cluster.fleet_2.cluster_registration_token[0].command
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig_2"
    }
  }
}