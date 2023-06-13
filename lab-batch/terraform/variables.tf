variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Compute Environment(s)
################################################################################

variable "compute_environments" {
  description = "Map of compute environment definitions to create"
  type        = any
  default     = {}
}

################################################################################
# Compute Environment - Instance Role
################################################################################

variable "create_instance_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "instance_iam_role_name" {
  description = "Cluster instance IAM role name"
  type        = string
  default     = null
}

variable "instance_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`instance_iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "instance_iam_role_path" {
  description = "Cluster instance IAM role path"
  type        = string
  default     = null
}

variable "instance_iam_role_description" {
  description = "Cluster instance IAM role description"
  type        = string
  default     = null
}

variable "instance_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "instance_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = list(string)
  default     = []
}

variable "instance_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Compute Environment - Service Role
################################################################################

variable "create_service_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = true
}

variable "service_iam_role_name" {
  description = "Batch service IAM role name"
  type        = string
  default     = null
}

variable "service_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`service_iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "service_iam_role_path" {
  description = "Batch service IAM role path"
  type        = string
  default     = null
}

variable "service_iam_role_description" {
  description = "Batch service IAM role description"
  type        = string
  default     = null
}

variable "service_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "service_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = list(string)
  default     = []
}

variable "service_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# Compute Environment - Spot Fleet Role
################################################################################
/*
variable "create_spot_fleet_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role"
  type        = bool
  default     = false
}

variable "spot_fleet_iam_role_name" {
  description = "Spot fleet IAM role name"
  type        = string
  default     = null
}

variable "spot_fleet_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`spot_fleet_iam_role_name`) is used as a prefix"
  type        = string
  default     = true
}

variable "spot_fleet_iam_role_path" {
  description = "Spot fleet IAM role path"
  type        = string
  default     = null
}

variable "spot_fleet_iam_role_description" {
  description = "Spot fleet IAM role description"
  type        = string
  default     = null
}

variable "spot_fleet_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "spot_fleet_iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = list(string)
  default     = []
}

variable "spot_fleet_iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}
*/

################################################################################
# Job Queue
################################################################################

variable "create_job_queues" {
  description = "Determines whether to create job queues"
  type        = bool
  default     = true
}

variable "job_queues" {
  description = "Map of job queue and scheduling policy defintions to create"
  type        = any
  default     = {}
}

################################################################################
# Scheduling Policy
################################################################################

# Scheduling policy is nested under job queue defintion

################################################################################
# Job Definitions
################################################################################

variable "job_definitions" {
  description = "Map of job definitions to create"
  type        = any
  default     = {}
}

variable "create_job_definitions" {
  description = "Determines whether to create the job definitions defined"
  type        = bool
  default     = true
}
