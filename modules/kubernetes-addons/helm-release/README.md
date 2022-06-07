# Helm Release module

Terraform module which creates a Helm release.

This module intentionally violates the "do not wrap a single resource in a module" rule. This is done to in order to allow passing a single variable object (`release`) that contains the pertinent attributes, reducing the number of exposed variables down to one. It is possible to use this module on its own externally, but this design decision was made to make the brokerage of information between sub-module and parent module through less variables but still providing the full breadth of access to the underlying resource.

## Usage

The minimium required attributes are shown below:

```hcl
module "example_helm_release" {
  source = "./helm-release"

  create = true

  release = {
    name        = "cluster-autoscaler"
    chart       = "cluster-autoscaler"
    repository  = "https://kubernetes.github.io/autoscaler"
  }
}
```

The full breadth of attributes can be found under the [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) resource, where all attributes supported are nested under the top-level `release` variable as shown above.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects all resources) | `bool` | `true` | no |
| <a name="input_release"></a> [release](#input\_release) | Wrapper variable around Helm release configuration values to allow upstream use of module to define only one variable per release | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_version"></a> [app\_version](#output\_app\_version) | The version number of the application being deployed |
| <a name="output_chart"></a> [chart](#output\_chart) | The name of the chart |
| <a name="output_name"></a> [name](#output\_name) | Name is the name of the release |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Name of Kubernetes namespace |
| <a name="output_revision"></a> [revision](#output\_revision) | Version is an int32 which represents the version of the release |
| <a name="output_values"></a> [values](#output\_values) | The compounded values from `values` and `set*` attributes |
| <a name="output_version"></a> [version](#output\_version) | A SemVer 2 conformant version string of the chart |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
