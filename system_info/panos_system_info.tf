provider "panos" {
    hostname = "${var.hostname}"
    api_key = "${var.api_key}"
}

data "panos_system_info" "config" {}
