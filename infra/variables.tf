#project

variable "project_name" {
  description = "prefixo de todos os recursos lançados no projeto para identificação"
  type        = string
  default     = "event-driven"
}

#api_gateway

variable "stage" {
  description = "nome do stage da api gateway"
  type        = string
  default     = "dev"
}

#sqs

#aws_region

variable "aws_region" {
  description = "região AWS"
  type        = string
  default     = "sa-east-1"
}

#tags

variable "tag_Environment" {
  description = "tag de Environment"
  type        = string
  default     = "dev"
}

variable "tag_Project" {
  description = "tag de Project"
  type        = string
  default     = "event-driven"
}