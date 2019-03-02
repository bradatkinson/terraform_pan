# azure_hub_pano_deploy

Terraform configuration to configure Panorama for an Azure hub deployment. The configuration file configures the templates, template stack, interfaces, zones, virtual routers, device group, address object, and security policies in Panorama.  It then commits the changes to Panorama and then pushes the changes to the specified firewalls.

## Built With

[Palo Alto Networks Device Framework (pandevice)](https://github.com/PaloAltoNetworks/pandevice)

## Deployment

All files within the folder should be deployed in the same directory for proper file execution.

## Prerequisites

Update `config.py`, `pano_vars.tf`, `secrets.tfvars`, and `static_routes.json` files with correct values before operating.

## Operating

The below command will execute the Terraform configuration file utilizing the secrets variable file containing the Panorama API key.

```terraform
terraform apply -var-file="secrets.tfvars"
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
