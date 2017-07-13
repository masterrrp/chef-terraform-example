#!/bin/bash

help() {

	cat << END

	Usage:

	$0 -o <test|deploy|omni|destroy> -v <cookbook_version> or -e <chef_environment>

	test: runs Chef Kitchen "test"
	deploy: runs Packer back if neccessary then Terrafor Plan/apply
	omni: runs test then deploy
	destroy: runs Terraform Destroy

	-v cookbook_version:	the cookbook version you would like to launch
	-e chef_environment:	the environment role which will be version locked to specific cookbook version (e.g. dev=0.1.2, staging=0.1.1, prod=0.1.0)

	Example:  $0 omni

END

}


testing() {
	test_result=$( cd cookbooks/webserver ; kitchen test )
	echo "$test_result"
	test_result=$( echo "$test_result" | grep "Test Summary:" | grep "0 failures" )
	return
}

deploy() {
	# set chef_run_list
	if [[ -z "$environment" ]] && [[ -z "$version" ]]; then
			environment=dev
			version=$( knife spork check webserver -y --environment $environment | sed -n '7p' | tr -d " " )
	elif [[ ! -z "$environment" ]]; then
			version=$( knife spork check webserver -y --environment $environment | sed -n '7p' | tr -d " " )
	elif [[ ! -z "$version" ]]; then
			environment=dev
			search_result=$( knife spork check webserver -y | tail -n +7 | grep "*$version" | tr -d "*" )
			if [[ ! -z "$search_result" ]]; then
					chef_run_list="recipe[webserver@${version}]"
			else
					echo -e "$0: Version $version doesn't exist."
					echo -e "Please use \"knife spork check webserver\" to view available versions"
					exit 1
			fi
	else
			search_result=$( knife spork check webserver -y | tail -n +7 | grep "*$version" | tr -d "*" )
			if [[ ! -z "$search_result" ]]; then
					chef_run_list="recipe[webserver@${version}]"
			else
					echo -e "$0: Version $version doesn't exist."
					echo -e "Please use \"knife spork check webserver\" to view available versions"
					exit 1
			fi
	fi

	# find latest ami
	remote_ami="$( aws ec2 describe-images --filters Name=tag-key,Values=Chef_Cookbook_Version Name=tag-value,Values=$version --query 'Images[*].[ImageId, CreationDate]' --output text | sort -k2 | tail -n1 | awk '{print $1}' )"

	# if latest exists just deploy it
	if [[ ! -z "$remote_ami" ]]; then
			make plan AMI="$remote_ami" ADMIN_IP="$admin_ip" $environment_vars
			make apply AMI="$remote_ami" ADMIN_IP="$admin_ip" $environment_vars
	# if no ami bake one then deploy it
	else
			make bake CHEF_ENVIRONMENT="$environment" CHEF_COOKBOOK_VERSION="$version" CHEF_RUN_LIST="$chef_run_list" $environment_vars
			ami="$(jq -r '.builds[] | .artifact_id' manifest.json | cut -d ":" -f 2 )"
			make plan AMI="$ami" ADMIN_IP="$admin_ip" $environment_vars
			make apply AMI="$ami" ADMIN_IP="$admin_ip" $environment_vars
	fi
}

omni() {
	test
	if [[ ! -z "$test_result" ]]; then
			# compare locale against remote
			knife spork check webserver -y
			spork_result=$( knife spork upload webserver )
			echo "$spork_result"
			version=$( echo "$spork_result" | grep "Successfully uploaded" | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/' )
	else
			exit 1
	fi
	deploy
}

destroy() {
	make destroy AMI="$ami" ADMIN_IP="$admin_ip" $environment_vars
}

# Checking prerequisites
[[ ! -x "$(which terraform)" ]] && echo "Couldn't find terraform in your PATH. Please see https://www.terraform.io/downloads.html" && exit 1
[[ ! -x "$(which packer)" ]] && echo "Couldn't find packer in your PATH." && exit 1
[[ ! -x "$(which chef)" ]] && echo "Couldn't find packer in your PATH." && exit 1
[[ ! -x "$(which curl)" ]] && echo "Couldn't find curl in your PATH." && exit 1
[[ ! -x "$(which ssh)" ]] && echo "Couldn't find ssh in your PATH." && exit 1
[[ ! -x "$(which ssh-keygen)" ]] && echo "Couldn't find ssh-keygen in your PATH." && exit 1
[[ ! -x "$(which jq)" ]] && echo "Couldn't find jq in your PATH." && exit 1
[[ ! -x "$(which aws)" ]] && echo "Couldn't find aws in your PATH." && exit 1

# Check to make sure all the variables are set as expected
if [[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]] || [[ -z "$CHEF_SERVER_URL" ]] || [[ -z "$CHEF_CLIENT_NAME" ]] || [[ -z "$CHEF_KEY_PATH" ]] ; then
		help
		ENV_VARS=( "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "CHEF_SERVER_URL" "CHEF_CLIENT_NAME" "CHEF_KEY_PATH" )
		for var in ${ENV_VARS[@]}; do
		  	if [[ ! -n "${!var}" ]]; then
						[[ -z "$echo_once" ]] && echo "# Please set the required environment variables!" ; echo_once=done
		    		echo "export $var=\"\""
				fi
		done
		exit 1
fi

ami= environment= version=

# Getting all the options
while getopts :o:a:e:v: opt; do
	case $opt in
	o)
		option=$OPTARG
  ;;
  a)
		ami=$OPTARG
  ;;
  e)
  	environment=$OPTARG
  ;;
	v)
  	version=$OPTARG
  ;;
  :)
	  echo "Option -$OPTARG requires an argument." >&2
	  exit 1
  esac
done

# setting environment_vars for easy access
environment_vars="AWS_ACCESS_KEY_ID=\"$AWS_ACCESS_KEY_ID\" AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET_ACCESS_KEY\" CHEF_SERVER_URL=\"$CHEF_SERVER_URL\" CHEF_CLIENT_NAME=\"$CHEF_CLIENT_NAME\" CHEF_KEY_PATH=\"$CHEF_KEY_PATH\""

# generate the SSH key pair, if it doesn't exist
if [[ ! -f "ssh_keys/id_rsa_example" ]]; then
	echo "Generating 4096-bit RSA SSH key pair. This can take a few seconds."
	ssh-keygen -t rsa -b 4096 -f ssh_keys/id_rsa_example -N ""
fi

# grab external IP for the security groups
admin_ip=$(curl -s http://ipinfo.io/ip)
[[ ! "$admin_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && echo "Couldn't determine your external IP: $admin_ip" && exit 1


case "$option" in
'test')
	testing
;;
'deploy')
	deploy
;;
'omni')
	omni
;;
'destroy')
	destroy
;;
'help')
	help
;;
*)
	echo "Option $option is invalid (test, deploy, omni, destroy help)" >&2
	help
	exit 1
esac
