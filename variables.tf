/**
 * Copyright 2023-2024 Nils Knieling
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# GOOGLE PROJECT

variable "project_id" {
  type        = string
  description = "The ID of the project"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Invalid project ID!"
  }
}

# IDENTITY POOL

variable "pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
  default     = "bitbucket-org"
  validation {
    condition = substr(var.pool_id, 0, 4) != "gcp-" && length(regex("([a-z0-9-]{4,32})", var.pool_id)) == 1
    error_message = join(" ", [
      "The 'pool_id' value should be 4-32 characters, and may contain the characters [a-z0-9-].",
      "The prefix 'gcp-' is reserved and can't be used in a pool ID."
    ])
  }
}

variable "pool_display_name" {
  type        = string
  description = "Workload Identity Pool display name"
  default     = "bitbucket.org"
}

variable "pool_description" {
  type        = string
  description = "Workload Identity Pool description"
  default     = "Workload Identity Pool for Bitbucket (Terraform managed)"
}

variable "pool_disabled" {
  type        = bool
  description = "Workload Identity Pool disabled"
  default     = false
}

# IDENTITY POOL PROVIDER

variable "provider_id" {
  type        = string
  description = "Workload Identity Pool Provider ID"
  default     = "bitbucket-org-oidc"
  validation {
    condition = substr(var.provider_id, 0, 4) != "gcp-" && length(regex("([a-z0-9-]{4,32})", var.provider_id)) == 1
    error_message = join(" ", [
      "The 'provider_id' value should be 4-32 characters, and may contain the characters [a-z0-9-].",
      "The prefix 'gcp-' is reserved and can't be used in a provider ID."
    ])
  }
}

variable "provider_display_name" {
  type        = string
  description = "Workload Identity Pool Provider display name"
  default     = "bitbucket.org OIDC"
}

variable "provider_description" {
  type        = string
  description = "Workload Identity Pool Provider description"
  default     = "Workload Identity Pool Provider for Bitbucket (Terraform managed)"
}

variable "provider_disabled" {
  type        = bool
  description = "Workload Identity Pool Provider disabled"
  default     = false
}

variable "issuer_uri" {
  type        = string
  description = "Bitbucket identity provider URL"
}

variable "allowed_audiences" {
  type        = list(string)
  description = "Bitbucket identity provider allowed audiences"
}

variable "attribute_mapping" {
  type        = map(string)
  description = "Workload Identity Pool Provider attribute mapping"
  default = {
    # Default attributes used in:
    # https://registry.terraform.io/modules/Cyclenerd/wif-service-account/google/latest
    "google.subject"       = "assertion.sub"            # Subject
    "attribute.sub"        = "attribute.sub"            # Subject
    "attribute.repository" = "assertion.repositoryUuid" # The repository (UUID) from where the workflow is running
    # More
    "attribute.aud"            = "attribute.aud"           # Audience
    "attribute.iss"            = "attribute.iss"           # Issuer
    "attribute.step_uuid"      = "assertion.stepUuid"      # Step UUID
    "attribute.branch_name"    = "assertion.branchName"    # Branch name
    "attribute.pipeline_uuid"  = "assertion.pipelineUuid"  # Pipeline UUID
    "attribute.workspace_uuid" = "assertion.workspaceUuid" # Workspace UUID
  }
}

variable "attribute_condition" {
  type        = string
  description = "(Optional) Workload Identity Pool Provider attribute condition expression"
  default     = null
}