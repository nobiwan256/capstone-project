variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key for authentication"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key for authentication"
  type        = string
}

variable "AWS_SESSION_TOKEN" {
  description = "AWS Session Token for temporary credentials (required for Vocareum Labs)"
  type        = string
  default     = null
}

variable "AWS_REGION" {
  description = "AWS Region for deployment"
  type        = string
  default     = "us-west-2"
}
