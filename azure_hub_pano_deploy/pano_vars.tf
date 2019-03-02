variable "api_key" {
    description = "Panorama API Key"
}

variable "hostname" {
    description = "Panorama Mgmt IP Address"
    default = "<MGMT_IP>"
}

variable "fw_serial_1" {
    description = "Firewall 1 Serial Number"
    default = "<FW_1_SERIAL_NO>"
}

variable "fw_serial_2" {
    description = "Firewall 2 Serial Number"
    default = "<FW_2_SERIAL_NO>"
}

variable "level_1_template_name" {
    description = "Level 1 - Azure firewall specific settings"
    default = "1 - Azure FW"
}

variable "level_2_template_name" {
    description = "Level 2 - Azure region specific settings"
    default = "2 - Azure Region"
}

variable "level_3_template_name" {
    description = "Level 3 - Azure items that are common to ALL deployed firewalls"
    default = "3 - Azure Global"
}

variable "template_stack_name" {
    description = "Azure Hub Template Stack"
    default = "Azure Hub"
}

variable "device_group_name" {
    description = "Azure Hub Device Group"
    default = "Azure Hub"
}

variable "azure_lb" {
    description = "Azure LB IP Address"
    default = "168.63.129.16"
}
