#project

variable "project_name" {
  description = "prefixo de todos os recursos lançados no projeto para identificação"
  type        = string
  default     = "event-driven"
}

# repositório do GitHub que tem permissão para assumir a função OIDC.

variable "github_allowed_repo_and_branch" {
  description = "O repositório GitHub que tem permissão para assumir a função OIDC."
  type        = string

  # caso queira testar em um fork altere aqui
  default     = "repo:GabrielLinharesRamos/aws-event-driven-order-processing:ref:refs/heads/main"
}


#api_gateway

variable "stage" {
  description = "nome do stage da api gateway"
  type        = string
  default     = "dev"
}

#dynamoDB

variable "orders_table" {
  description = "nome da tabela do dynamoDB"
  type        = string
  default     = "event-driven-orders"
}

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