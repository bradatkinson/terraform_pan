#---------------------------------------------
#  AZURE HUB DEPLOYMENT INTO PANORAMA
#---------------------------------------------

provider "panos" {
    hostname = "${var.hostname}"
    api_key = "${var.api_key}"
}

#---------------------------------------------
#  TEMPLATES
#---------------------------------------------

resource "panos_panorama_template" "level_1_azure_template" {
    name = "${var.level_1_template_name}"
    description = "Azure firewall specific settings"
}

resource "panos_panorama_template" "level_2_azure_template" {
    name = "${var.level_2_template_name}"
    description = "Azure region specific settings"
}

resource "panos_panorama_template" "level_3_azure_template" {
    name = "${var.level_3_template_name}"
    description = "Azure items that are common to ALL deployed firewalls"
}

resource "panos_panorama_template_stack" "azure_template_stack" {
    name = "${var.template_stack_name}"
    description = "Template stack for Azure firewalls"
    templates = ["${panos_panorama_template.level_1_azure_template.name}",
                 "${panos_panorama_template.level_2_azure_template.name}",
                 "${panos_panorama_template.level_3_azure_template.name}"]
    devices = ["${var.fw_serial_1}", "${var.fw_serial_2}"]
}

#---------------------------------------------
#  INTERFACES
#---------------------------------------------

resource "panos_panorama_ethernet_interface" "eth1" {
    name = "ethernet1/1"
    vsys = "vsys1"
    mode = "layer3"
    enable_dhcp = true
    create_dhcp_default_route = true
    dhcp_default_route_metric = 10
    management_profile = "${panos_panorama_management_profile.health_probes.name}"
    comment = "Public"
    template = "${panos_panorama_template.level_1_azure_template.name}"
}

resource "panos_panorama_ethernet_interface" "eth2" {
    name = "ethernet1/2"
    vsys = "vsys1"
    mode = "layer3"
    enable_dhcp = true
    create_dhcp_default_route = true
    dhcp_default_route_metric = 10
    management_profile = "${panos_panorama_management_profile.health_probes.name}"
    comment = "Private"
    template = "${panos_panorama_template.level_1_azure_template.name}"
}

resource "panos_panorama_ethernet_interface" "eth3" {
    name = "ethernet1/3"
    vsys = "vsys1"
    mode = "layer3"
    enable_dhcp = true
    create_dhcp_default_route = true
    dhcp_default_route_metric = 10
    management_profile = "${panos_panorama_management_profile.health_probes.name}"
    comment = "Gateway"
    template = "${panos_panorama_template.level_1_azure_template.name}"
}

#---------------------------------------------
#  MGMT PROFILE
#---------------------------------------------

resource "panos_panorama_management_profile" "health_probes" {
    name = "Allow Health Probes"
    template = "${panos_panorama_template.level_1_azure_template.name}"
    ping = true
    ssh = true
    permitted_ips = ["10.0.0.0/8", "168.63.129.16/32"]
}

#---------------------------------------------
#  ZONES
#---------------------------------------------

resource "panos_panorama_zone" "public_zone" {
    name = "public"
    template = "${panos_panorama_template.level_1_azure_template.name}"
    mode = "layer3"
    interfaces = ["${panos_panorama_ethernet_interface.eth1.name}"]
}

resource "panos_panorama_zone" "private_zone" {
    name = "private"
    template = "${panos_panorama_template.level_1_azure_template.name}"
    mode = "layer3"
    interfaces = ["${panos_panorama_ethernet_interface.eth2.name}"]
}

resource "panos_panorama_zone" "gateway_zone" {
    name = "gateway"
    template = "${panos_panorama_template.level_1_azure_template.name}"
    mode = "layer3"
    interfaces = ["${panos_panorama_ethernet_interface.eth3.name}"]
}

#---------------------------------------------
#  VIRTUAL ROUTERS
#---------------------------------------------

resource "panos_panorama_virtual_router" "public_vr" {
    name = "public-vr"
    template = "${panos_panorama_template.level_1_azure_template.name}"
    interfaces = ["${panos_panorama_ethernet_interface.eth1.name}"]
}

resource "panos_panorama_virtual_router" "private_vr" {
    name = "private-vr"
    template = "${panos_panorama_template.level_1_azure_template.name}"
    interfaces = ["${panos_panorama_ethernet_interface.eth2.name}"]
}

resource "panos_panorama_virtual_router" "gateway_vr" {
    name = "gateway-vr"
    template = "${panos_panorama_template.level_1_azure_template.name}"
    interfaces = ["${panos_panorama_ethernet_interface.eth3.name}"]
}

#---------------------------------------------
#  DEVICE GROUP
#---------------------------------------------

resource "panos_panorama_device_group" "azure_device_group" {
    name = "${var.device_group_name}"
    description = "${var.device_group_name}"
    device {
        serial = "${var.fw_serial_1}"
    }
    device {
        serial = "${var.fw_serial_2}"
    }
}

#---------------------------------------------
#  ADDRESS OBJECTS
#---------------------------------------------

resource "panos_panorama_address_object" "azure_lb" {
    name = "Azure LB - ${var.azure_lb}"
    value = "${var.azure_lb}/32"
    description = "Azure Load Balancer"
    type = "ip-netmask"
    device_group = "${panos_panorama_device_group.azure_device_group.name}"
}

#---------------------------------------------
#  SECURITY POLICIES
#---------------------------------------------

resource "panos_panorama_security_policy" "vsys1" {
    device_group = "${panos_panorama_device_group.azure_device_group.name}"
    rule {
        name = "ICMP Any"
        description = "Allow ping to/from any hosts"
        source_zones = ["any"]
        source_addresses = ["any"]
        source_users = ["any"]
        hip_profiles = ["any"]
        destination_zones = ["any"]
        destination_addresses = ["any"]
        applications = ["ping", "icmp", "traceroute"]
        services = ["application-default"]
        categories = ["any"]
        action = "allow"
    }
    rule {
        name = "Health Probes"
        description = "Allow Health Probes from Azure Load Balancer using SSH"
        source_zones = ["any"]
        source_addresses = ["${panos_panorama_address_object.azure_lb.name}"]
        source_users = ["any"]
        hip_profiles = ["any"]
        destination_zones = ["any"]
        destination_addresses = ["any"]
        applications = ["ssh"]
        services = ["application-default"]
        categories = ["any"]
        action = "allow"
    }
    rule {
        name = "Web Browsing"
        description = "Allow internal to Internet for web browsing"
        source_zones = ["${panos_panorama_zone.private_zone.name}"]
        source_addresses = ["any"]
        source_users = ["any"]
        hip_profiles = ["any"]
        destination_zones = ["${panos_panorama_zone.public_zone.name}"]
        destination_addresses = ["any"]
        applications = ["web-browsing", "ssl"]
        services = ["application-default"]
        categories = ["any"]
        action = "allow"
    }
}

#---------------------------------------------
#  PYTHON SCRIPTS
#---------------------------------------------

resource "null_resource" "static_route" {
  provisioner "local-exec" {
    command = "./static_route_add.py"
    interpreter = ["python"]
  }
}

resource "null_resource" "commit" {
  provisioner "local-exec" {
    command = "./commit.py"
    interpreter = ["python"]
  }
}