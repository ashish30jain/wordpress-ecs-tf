variable "database_master_password" {
sensitive = true
}
variable "env" {
    default = "dev"
    type = "String"
}