# Google Cloud Workload Identity for Bitbucket

[![Badge: Google Cloud](https://img.shields.io/badge/Google%20Cloud-%234285F4.svg?logo=google-cloud&logoColor=white)](https://github.com/Cyclenerd/terraform-google-wif-bitbucket#readme)
[![Badge: Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?logo=terraform&logoColor=white)](https://github.com/Cyclenerd/terraform-google-wif-bitbucket#readme)
[![Badge: Bitbucket](https://img.shields.io/badge/Bitbucket-0052CC.svg?logo=bitbucket&logoColor=white)](https://github.com/Cyclenerd/terraform-google-wif-bitbucket#readme)
[![Badge: CI](https://github.com/Cyclenerd/terraform-google-wif-bitbucket/actions/workflows/ci.yml/badge.svg)](https://github.com/Cyclenerd/terraform-google-wif-bitbucket/actions/workflows/ci.yml)
[![Badge: License](https://img.shields.io/github/license/cyclenerd/terraform-google-wif-bitbucket)](https://github.com/Cyclenerd/terraform-google-wif-bitbucket/blob/master/LICENSE)

This Terraform module creates a Workload Identity Pool and Provider for Bitbucket.

Service account keys are a security risk if compromised.
Avoid service account keys and instead use the [Workload Identity Federation](https://github.com/Cyclenerd/google-workload-identity-federation#readme).
For more information about Workload Identity Federation and how to best authenticate service accounts on Google Cloud, please see my GitHub repo [Cyclenerd/google-workload-identity-federation](https://github.com/Cyclenerd/google-workload-identity-federation#readme).

> There are also ready-to-use Terraform modules
> for [GitHub](https://github.com/Cyclenerd/terraform-google-wif-github#readme)
> and [GitLab](https://github.com/Cyclenerd/terraform-google-wif-bitbucket#readme).

## Example

Create Workload Identity Pool and Provider:

```hcl
# Create Workload Identity Pool Provider for Bitbucket
module "bitbucket-wif" {
  source            = "Cyclenerd/wif-bitbucket/google"
  version           = "~> 1.0.0"
  project_id        = "your-project-id"
  issuer_uri        = "your-bitbucket-identity-provider-url"
  allowed_audiences = "your-bitbucket-identity-provider-audience"
}

# Get the Workload Identity Pool Provider resource name for Bitbucket pipeline configuration
output "bitbucket-workload-identity-provider" {
  description = "The Workload Identity Provider resource name"
  value       = module.bitbucket-wif.provider_name
}
```

If you do not yet know the required values, navigate to the Bitbucket repsoitory settings and click the menu item "OpenID Connect".

Here you will find the OIDC information:

* Identity provider URL: `issuer_uri`
* Audience: `allowed_audiences`
* Repository UUID: `repository`

> An example of a working Bitbucket pipeline configuration (`bitbucket-pipelines.yml`) can be found on [Bitbucket](https://bitbucket.org/cyclenerd/google-workload-identity-federation-for-bitbucket/src/master/bitbucket-pipelines.yml).

Allow service account to login via Workload Identity Provider and limit login only from the Bitbucket repository (UUID):

```hcl
# Get existing service account for Bitbucket pipeline
data "google_service_account" "bitbucket" {
  project    = "your-project-uuid"
  account_id = "existing-account-for-bitbucket-pipeline"
}

# Allow service account to login via WIF and only from Bitbucket repository (UUID)
module "bitbucket-service-account" {
  source     = "Cyclenerd/wif-service-account/google"
  version    = "~> 1.0.0"
  project_id = "your-project-id"
  pool_name  = module.bitbucket-wif.pool_name
  account_id = data.google_service_account.bitbucket.account_id
  repository = "your-bitbucket-repository-uuid"
}
```

> Terraform module [`Cyclenerd/wif-service-account/google`](https://github.com/Cyclenerd/terraform-google-wif-service-account) is used.

👉 [**More examples**](https://github.com/Cyclenerd/terraform-google-wif-bitbucket/tree/master/examples)

## OIDC Token Attribute Mapping

> The attributes `attribute.sub` and `attribute.repository` are used in the Terrform module [Cyclenerd/wif-service-account/google](https://github.com/Cyclenerd/terraform-google-wif-service-account).
> Please do not remove these attributes.

Default attribute mapping:

| Attribute                         | Claim                             | Description |
|-----------------------------------|-----------------------------------|-------------|
| `google.subject`                  | `assertion.sub`                   | Subject
| `attribute.sub`                   | `assertion.sub`                   | Defines the subject claim that is to be validated by the cloud provider. This setting is essential for making sure that access tokens are only allocated in a predictable way.
| `attribute.repository`            | `assertion.repositoryUuid`        | The repository (UUID) from where the workflow is running
| `attribute.aud`                   | `assertion.aud`                   | Intended audience for the token
| `attribute.iss`                   | `assertion.iss`                   | Issuer of the token
| `attribute.step_uuid`             | `assertion.stepUuid`              | Step UUID
| `attribute.branch_name`           | `assertion.branchName`            | Branch name
| `attribute.pipeline_uuid`         | `assertion.pipelineUuid`          | Pipeline UUID
| `attribute.workspace_uuid`        | `assertion.workspaceUuid`         | Workspace UUID

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.61.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_audiences"></a> [allowed\_audiences](#input\_allowed\_audiences) | Bitbucket identity provider allowed audiences | `string` | n/a | yes |
| <a name="input_attribute_condition"></a> [attribute\_condition](#input\_attribute\_condition) | (Optional) Workload Identity Pool Provider attribute condition expression | `string` | `null` | no |
| <a name="input_attribute_mapping"></a> [attribute\_mapping](#input\_attribute\_mapping) | Workload Identity Pool Provider attribute mapping | `map(string)` | <pre>{<br>  "attribute.aud": "attribute.aud",<br>  "attribute.branch_name": "assertion.branchName",<br>  "attribute.iss": "attribute.iss",<br>  "attribute.pipeline_uuid": "assertion.pipelineUuid",<br>  "attribute.repository": "assertion.repositoryUuid",<br>  "attribute.step_uuid": "assertion.stepUuid",<br>  "attribute.sub": "attribute.sub",<br>  "attribute.workspace_uuid": "assertion.workspaceUuid",<br>  "google.subject": "assertion.sub"<br>}</pre> | no |
| <a name="input_issuer_uri"></a> [issuer\_uri](#input\_issuer\_uri) | Bitbucket identity provider URL | `string` | n/a | yes |
| <a name="input_pool_description"></a> [pool\_description](#input\_pool\_description) | Workload Identity Pool description | `string` | `"Workload Identity Pool for Bitbucket (Terraform managed)"` | no |
| <a name="input_pool_disabled"></a> [pool\_disabled](#input\_pool\_disabled) | Workload Identity Pool disabled | `bool` | `false` | no |
| <a name="input_pool_display_name"></a> [pool\_display\_name](#input\_pool\_display\_name) | Workload Identity Pool display name | `string` | `"bitbucket.org"` | no |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | Workload Identity Pool ID | `string` | `"bitbucket-org"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project | `string` | n/a | yes |
| <a name="input_provider_description"></a> [provider\_description](#input\_provider\_description) | Workload Identity Pool Provider description | `string` | `"Workload Identity Pool Provider for Bitbucket (Terraform managed)"` | no |
| <a name="input_provider_disabled"></a> [provider\_disabled](#input\_provider\_disabled) | Workload Identity Pool Provider disabled | `bool` | `false` | no |
| <a name="input_provider_display_name"></a> [provider\_display\_name](#input\_provider\_display\_name) | Workload Identity Pool Provider display name | `string` | `"bitbucket.org OIDC"` | no |
| <a name="input_provider_id"></a> [provider\_id](#input\_provider\_id) | Workload Identity Pool Provider ID | `string` | `"bitbucket-org-oidc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pool_id"></a> [pool\_id](#output\_pool\_id) | Identifier for the pool |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | The resource name for the pool |
| <a name="output_pool_state"></a> [pool\_state](#output\_pool\_state) | State of the pool |
| <a name="output_provider_id"></a> [provider\_id](#output\_provider\_id) | Identifier for the provider |
| <a name="output_provider_name"></a> [provider\_name](#output\_provider\_name) | The resource name of the provider |
| <a name="output_provider_state"></a> [provider\_state](#output\_provider\_state) | State of the provider |
<!-- END_TF_DOCS -->

## License

All files in this repository are under the [Apache License, Version 2.0](LICENSE) unless noted otherwise.

Based on [Terraform module for workload identity federation on GCP](https://github.com/mscribellito/terraform-google-workload-identity-federation) by [Michael S](https://github.com/mscribellito).