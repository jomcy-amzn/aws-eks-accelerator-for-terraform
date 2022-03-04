
locals {
  name                 = "ingress-nginx"
  service_account_name = "${local.name}-sa"
  namespace            = "nginx"
  default_helm_config = {
    name                       = local.name
    chart                      = local.name
    repository                 = "https://kubernetes.github.io/ingress-nginx"
    version                    = "4.0.17"
    namespace                  = local.namespace
    timeout                    = "1200"
    create_namespace           = false
    values                     = local.default_helm_values
    set                        = []
    set_sensitive              = null
    lint                       = false
    verify                     = false
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false
    cleanup_on_fail            = false
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    wait                       = true
    wait_for_jobs              = false
    dependency_update          = false
    replace                    = false
    description                = "The NGINX HelmChart Ingress Controller deployment configuration"
    postrender                 = ""
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", { service_account_name = local.service_account_name })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    eks_cluster_id                    = var.addon_context.eks_cluster_id
    irsa_iam_policies                 = concat([aws_iam_policy.this.arn], var.irsa_policies)
    irsa_iam_permissions_boundary     = var.irsa_iam_permissions_boundary
    tags                              = var.tags
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
