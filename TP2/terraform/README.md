# Terraform configuration

This configuration creates required AWS resources

# Usage

To run this, you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

To undo deployment and destroy the infrastructure:
```bash
$ terraform destroy
```

## How-To:

In order to successfully run the `terraform plan`:

- The AWS CLI must be authenticated (credentials located in the `~/.aws/credentials` file)
- The private key `labuser.pem` must be located at the root of the `TP2/` directory.

Having the private key allows us to launch a `remote-exec` privisioner, which in turn gives us the output log of the `user_data` script and lets us know when everything is finished.