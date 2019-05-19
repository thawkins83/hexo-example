This repo is to be used with the following [blog entry](http://blog.hawktail.io/2019/05/04/How-I-Made-This-Blog/).

If you would like to use S3 Backend for Terraform, edit the `vars/backend-config.tfvars` file accordingly, then run the following command.  

```bash
$ terraform init -backend-config=vars/backend-config.tfvars
```

Otherwise, run
```bash
$ terraform init
```

Edit the `vars/blog.tfvars` file with appropriate values and run the follow command.

```bash
$ terraform apply -var-file=vars/blog.tfvars
```