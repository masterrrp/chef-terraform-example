# chef-terraform-example

Rudimentary wrapper script to achieve simple CI/CD pipeline demo. Built with Packer AMI builds, Terraform rolling updates, functioning ASG's, Chef Kitchen testing, Chef Server cookbook version and version management AMI's.

## Getting Started

Clone the repo and setup the prerequisites and off you go.

### Prerequisites

You will need the following installed:

* Git
* Packer
* Terraform
* ChefDK
* Chef Server (sign up for a free one: https://api.chef.io/signup)
* jq
* awscli
* curl
* SSH
* SSH-Keygen

Environment variables expected:

* AWS_ACCESS_KEY_ID="XYXYXYXYXYXYXYXY"
* AWS_SECRET_ACCESS_KEY="XYXYXYXYXYXYXYYXYXYXYXYXYXYYXYXYXYXY"
* CHEF_SERVER_URL="https://api.chef.io/organizations/orgname"
* CHEF_CLIENT_NAME="username"
* CHEF_KEY_PATH="/absolute/path/.ssh/chef.pem"

### Test

You makes changes to your local cookbook or tests and want to test them locally, use this command.

```
./chef-terraform-example.sh -o test
```

### Omni

This step runs Kitchen Test, when it passes it then bakes a new AMI then deploys it.

```
./chef-terraform-example.sh -o omni
```


### Deploy

Use this option to launch a specific version of the cookbook or a environment which has cookbook version pinnings.

Say you want to deploy the latest available development AMI build, use the following:
```
./chef-terraform-example.sh -o deploy -e dev
```

Or for example you want to launch cookbook@0.1.5:
```
./chef-terraform-example.sh -o deploy -v 0.1.5
```


### Destroy

Use this to clean up all the Terraform resources after you are done with the demo (except AMI's).

```
./chef-terraform-example.sh -o destroy
```

### TODO
- [ ] Maybe pull over some more knife spork (e.g. promote)
- [ ] Move a lot of functionality over to Makefile
- [ ] Error handling on failed Packer, Terraform builds
- [ ] Clean up wrapper
- [ ] Expand the docs
- [ ] Acknowledgments

### Acknowledgments
...WIP
