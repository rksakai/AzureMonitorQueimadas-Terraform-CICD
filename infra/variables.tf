variable "location" {
  default = "brazilsouth"
}

variable "resource_group_name" {
  default = "rg-monitor-queimadas"
}

variable "postgres_admin_user" {
  default = "adminuser"
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

variable "postgres_db_name" {
  default = "db_queimadas"
}

variable "function_app_name" {
  default = "func-queimadas"
}

variable "storage_account_name" {
  default = "stqueimadasfunc"
}

# As variaveis acr_name, aci_name e webapp_image_tag serao
# adicionadas neste mesmo arquivo no Dia 2.
