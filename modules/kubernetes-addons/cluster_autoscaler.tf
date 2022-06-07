locals {
  cluster_autoscaler_namespace       = try(var.cluster_autoscaler_helm_release.namespace, "kube-system")
  cluster_autoscaler_service_account = try(var.cluster_autoscaler_helm_release.service_account, "cluster-autoscaler")
}

module "cluster_autoscaler" {
  source = "./helm-release"

  create = var.enable_cluster_autoscaler

  release = merge(
    # Default values
    {
      name        = "cluster-autoscaler"
      description = "Cluster AutoScaler helm Chart deployment configuration"
      namespace   = local.cluster_autoscaler_namespace
      chart       = "cluster-autoscaler"
      repository  = "https://kubernetes.github.io/autoscaler"
      set = [
        {
          # We are setting this to ensure its synchronized across the chart and IRSA role as well as helm created or user provided
          name  = "rbac.serviceAccount.name"
          value = local.cluster_autoscaler_service_account
        },
        {
          name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
          value = var.create_cluster_autoscaler_irsa ? module.cluster_autoscaler_irsa.iam_role_arn : var.cluster_autoscaler_irsa.iam_role_arn
        },
        {
          name  = "awsRegion"
          value = data.aws_region.current.name
        },
        {
          name  = "autoDiscovery.clusterName"
          value = var.eks_cluster_id
        },
      ]
    },
    # User values that can override the defaults
    var.cluster_autoscaler_helm_release
  )
}

module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.1.0"

  create_role = var.create_cluster_autoscaler_irsa

  role_name            = try(var.cluster_autoscaler_irsa.role_name, null)
  role_name_prefix     = try(var.cluster_autoscaler_irsa.role_name_prefix, "cluster-autoscaler-")
  role_path            = try(var.cluster_autoscaler_irsa.role_path, null)
  role_description     = try(var.cluster_autoscaler_irsa.role_description, null)
  max_session_duration = try(var.cluster_autoscaler_irsa.max_session_duration, null)

  role_permissions_boundary_arn = try(var.cluster_autoscaler_irsa.role_permissions_boundary_arn, null)
  assume_role_condition_test    = try(var.cluster_autoscaler_irsa.assume_role_condition_test, "StringEquals")
  policy_name_prefix            = try(var.cluster_autoscaler_irsa.policy_name_prefix, "AmazonEKS_")
  role_policy_arns              = try(var.cluster_autoscaler_irsa.role_policy_arns, {})

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [var.eks_cluster_id]

  oidc_providers = {
    this = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["${local.cluster_autoscaler_namespace}:${local.cluster_autoscaler_service_account}"]
    }
  }

  tags = var.tags
}
