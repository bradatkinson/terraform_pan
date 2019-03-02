# system_info

Terraform configuration for Palo Alto Network devices to retrieve system info.

## Deployment

All files within the folder should be deployed in the same directory for proper file execution.

## Prerequisites

Update `fw_vars.tf` and `secrets.tfvars` files with correct values before operating.

## Operating

The below command will execute the Terraform configuration file utilizing the secrets variable file containing the firewall API key.

```terraform
terraform apply -var-file="secrets.tfvars"
```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
