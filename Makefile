.PHONY: all bake plan apply destroy

ASG_NAME=$(shell terraform output asg_name)

bake:
	packer build -force \
	-var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
	-var "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" \
	-var "chef_environment=${CHEF_ENVIRONMENT}" \
	-var "chef_cookbook_version=${CHEF_COOKBOOK_VERSION}" \
	-var "chef_run_list=${CHEF_RUN_LIST}" \
	-var "chef_server_url"=${CHEF_SERVER_URL} \
	-var "chef_client_name"=${CHEF_CLIENT_NAME} \
	-var "chef_key_path"=${CHEF_KEY_PATH} \
	packer/aws/webserver.json

plan:
	terraform plan \
	-var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
	-var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
	-var "ami=${AMI}" \
	-var "admin_ip=${ADMIN_IP}"

apply:
	terraform apply \
	-var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
	-var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
	-var "ami=${AMI}" \
	-var "admin_ip=${ADMIN_IP}"


destroy:
	terraform destroy -force \
	-var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
	-var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
	-var "ami=${AMI}" \
	-var "admin_ip=${ADMIN_IP}"
