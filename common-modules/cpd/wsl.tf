
resource "local_file" "ws_cr_yaml" {
  content  = data.template_file.ws_cr.rendered
  filename = "${local.cpd_workspace}/ws_cr.yaml"
}

resource "local_file" "ws_sub_yaml" {
  content  = data.template_file.ws_sub.rendered
  filename = "${local.cpd_workspace}/ws_sub.yaml"
}

resource "local_file" "ws_catalog_yaml" {
  content  = data.template_file.ws_catalog.rendered
  filename = "${local.cpd_workspace}/ws_catalog.yaml"
}

resource "local_file" "ws_runtime_catalog_yaml" {
  content  = data.template_file.ws_runtime_catalog.rendered
  filename = "${local.cpd_workspace}/ws_runtime_catalog.yaml"
}

resource "local_file" "data_refinery_catalog.yaml" {
  content  = data.template_file.data_refinery_catalog.rendered
  filename = "${local.cpd_workspace}/data_refinery_catalog.yaml"
}

resource "null_resource" "install_ws" {
  count = var.watson_studio.enable == "yes" ? 1 : 0
  triggers = {
    namespace     = var.cpd_namespace
    cpd_workspace = local.cpd_workspace
  }
  provisioner "local-exec" {
    command = <<-EOF

echo 'Create DataRefinery catalog'
oc create -f ${self.triggers.cpd_workspace}/data_refinery_catalog.yaml
sleep 3
bash cpd/scripts/pod-status-check.sh ibm-cpd-datarefinery-operator-catalog openshift-marketplace

echo 'Create ws catalog'
oc create -f ${self.triggers.cpd_workspace}/ws_catalog.yaml
sleep 3
bash cpd/scripts/pod-status-check.sh ibm-cpd-ws-operator-catalog openshift-marketplace

echo 'Create ws runtime catalog'
oc create -f ${self.triggers.cpd_workspace}/ws_runtime_catalog.yaml
sleep 3
bash cpd/scripts/pod-status-check.sh ibm-cpd-ws-runtimes-operator-catalog openshift-marketplace

echo 'Create ws sub'
oc create -f ${self.triggers.cpd_workspace}/ws_sub.yaml
sleep 3
bash cpd/scripts/pod-status-check.sh ibm-cpd-ws-operator ${local.operator_namespace}

echo 'Create ws CR'
oc create -f ${self.triggers.cpd_workspace}/ws_cr.yaml
sleep 3
echo 'check the ws cr status'
bash cpd/scripts/check-cr-status.sh ws ws-cr ${var.cpd_namespace} wsStatus
EOF
  }
  depends_on = [
    local_file.ws_catalog_yaml,
    local_file.ws_runtime_catalog_yaml,
    local_file.ws_cr_yaml,
    local_file.ws_sub_yaml,
    module.machineconfig,
    null_resource.cpd_foundational_services,
    null_resource.login_cluster,
  ]
}

