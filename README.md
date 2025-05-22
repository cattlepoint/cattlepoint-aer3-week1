# cattlepoint-aer3-week1
Capstone Project for AWS ER - Week 1
#### Finalized May 2nd 2025

## Overview
* These instructions are intended for participants of the AWS Engagement Ready Class started in April 2025
* The goal of this week1 project is to verify minimal terraform (opentofu) competency and to ensure that the environment is working properly
* This project assumes that you have access to the eruser315 credentials
* This project also assumes that you are running the latest MacOS and have terminal access sufficient to install local applications

## Prerequisite
### This section is to ensure you have access to the AWS account and the necessary credentials
* Request access to private repo cattlepoint/cattlepoint-aer3-week1
* Login to [AWS Account eruser315account](https://eruser315account.signin.aws.amazon.com/console) using username eruser315 and password *****
* [Download AWS Access Keys](https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials/access-key-wizard) file eruser315_accessKeys.csv by selecting Command Line Interface (CLI) and I understand the above recommendation and want to proceed to create an access key -> Next

## 10 points – Build an environment to run Terraform (opentofu)
### This section installs the AWS CLI and configures it with the credentials from the CSV file
* If you haven't already done so, setup Homebrew on your MacOS following [these instructions](https://brew.sh/).
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
* Perform these steps in the MacOS terminal to install the AWS CLI
```sh
brew update && brew install awscli
```
* Next we need to configure the AWS CLI with the credentials from the CSV file. You can do this by running the following command in your terminal:
```sh
aws configure --profile eruser315
```
* When prompted, enter the access key and secret access key from the CSV file.  Set the default region to us-east-1 and the output format to json.  The command will look like this:
```sh
% aws configure --profile eruser315
AWS Access Key ID [****************GFJ2]:
AWS Secret Access Key [****************Ya3D]:
Default region name [us-east-1]:
Default output format [json]:
```
* Verify AWS credentials are working:
```sh
export AWS_PROFILE=eruser315
aws sts get-caller-identity
```
* Visually verify in output: arn:aws:iam::****:user/eruser315

## 10 points – Install the Terraform (opentofu) software and ensure it works properly
### This section installs the latest version of opentofu, project dependencies and verifies they are working
* Perform these steps in the MacOS terminal to install opentofu, git, github client, Kubernetes CLI, and eksctl:
```sh
brew update && brew install opentofu git gh kubectl eksctl
```
* Login to your github account following the instructions the below command provides:
```sh
gh login
```
* Verify the the github client is working:
```sh
gh auth status
```
* Expected output (contents will vary):
```sh
✓ Logged in to github.com account
```

* Verify the the Kubernetes CLI is working:
```sh
kubectl version --client
```

* Verify the the eksctl is working:
```sh
eksctl version
```

* Verify opentofu is working:
```sh
tofu version
```

## 20 points – Test the environment by creating a simple virtual machine
### This section builds out a simple EC2 instance in the us-east-1 region using the modules/bastion module with terraform (opentofu)
* Verify AWS credentials are working from Prerequisite:
```sh
export AWS_PROFILE=eruser315
aws sts get-caller-identity
```
* Visually verify in output: arn:aws:iam::****:user/eruser315
* Clone this repo locally:
```sh
gh repo clone cattlepoint/cattlepoint-aer3-week1
```
* Go into directory:
```sh
cd cattlepoint-aer3-week1/terraform/aws/capstone/modules/bastion
```
* Execute terraform deployment:
```sh
tofu init && tofu fmt && tofu plan -out=tfplan && tofu apply tfplan
```
* Expected output (id= will vary):
```sh
aws_instance.vm[0]: Creating...
aws_instance.vm[0]: Still creating... [10s elapsed]
aws_instance.vm[0]: Creation complete after 14s [id=i-0e8bb2d7b0bbda974]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

* Verify instance is running:
```sh
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=mycapstoneproject-bastion-0" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].{InstanceId:InstanceId, Name:Tags[?Key=='Name']|[0].Value, Status:State.Name}" \
  --output table
 ```

 * Expected output (id= will vary):
 ```sh
 -------------------------------------------------------------------
 |                        DescribeInstances                        |
 +----------------------+-------------------------------+----------+
 |      InstanceId      |             Name              | Status   |
 +----------------------+-------------------------------+----------+
 |  i-0e8bb2d7b0bbda974 |  mycapstoneproject-bastion-0  |  running |
 +----------------------+-------------------------------+----------+
 ```

* Cleanup the mess:
```sh
tofu destroy -auto-approve
```

* Expected output (id= will vary):
```sh
Plan: 0 to add, 0 to change, 1 to destroy.
aws_instance.vm[0]: Destroying... [id=i-0e8bb2d7b0bbda974]
aws_instance.vm[0]: Still destroying... [id=i-0e8bb2d7b0bbda974, 10s elapsed]
aws_instance.vm[0]: Still destroying... [id=i-0e8bb2d7b0bbda974, 20s elapsed]
aws_instance.vm[0]: Still destroying... [id=i-0e8bb2d7b0bbda974, 30s elapsed]
aws_instance.vm[0]: Destruction complete after 31s

Destroy complete! Resources: 1 destroyed.
```

## 50 points – Build a website similar to the Space Invaders site you built in class by reusing modules
### This section builds out the website infrastructure necessary and deploys the Space Invaders site using terraform (opentofu)
#### Section Overview
* The goal of this section is to build a Space Invaders using Terraform (opentofu) modules
* The modules are located in the modules directory
* modules/alb is the module for building out the Application Load Balancer (ALB) and Target Group
* modules/asg is the module for building out the Auto Scaling Group (ASG) and Launch Template
* modules/bastion is the module for building out the Bastion Host
* modules/securitygroups is the module for building out the Security Groups
* modules/vpc is the module for building out the VPC with Public and Private subnets, an Internet Gateway, and a public route table

#### Section steps to build the website infrastructure and deploy the site
* Verify AWS credentials are working from Prerequisite:
```sh
export AWS_PROFILE=eruser315
aws sts get-caller-identity
```
* Visually verify in output: arn:aws:iam::****:user/eruser315
* Clone this repo locally (if you have not already done so):
```sh
gh repo clone cattlepoint/cattlepoint-aer3-week1
```
* Go into directory:
```sh
cd cattlepoint-aer3-week1/terraform/aws/capstone/
```
* Execute terraform deployment:
```sh
tofu init && tofu fmt && tofu plan -out=tfplan && tofu apply tfplan
```
* Expected output (alb_dns_name= will vary):
```sh
Apply complete! Resources: 34 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = "capstonew1-alb-823550112.us-east-1.elb.amazonaws.com"
```
* Verify the ALB is working by going to the URL in your browser and playing the game (may take up to 5 minutes to load the first time [502 Bad Gateway = wait])
* Cleanup the mess:
```sh
tofu destroy -auto-approve
```
* Expected output:
```sh
module.bastion.aws_instance.vm[0]: Destruction complete after 41s

Destroy complete! Resources: 34 destroyed.
```

## 10 points – Put a copy of your code in Git, then destroy the infrastructure; leave the environment intact
### This section addresses the git repository requirement, distribution of code, and cleanup
* This repo you are viewing achieves github requirement for this section
* It is confirmed shared with instructor: jessetop (Collaborator)
* When done, clean up your resources by executing:
```sh
cd cattlepoint-aer3-week1/terraform/aws/capstone/
tofu destroy -auto-approve
```
* Execute this script to verify no EC2 instances, RDS instances, ELBs, NAT Gateways, non-default VPCs or EKS clusters are left in the allowed regions:
```sh
cd cattlepoint-aer3-week1/
bash verifyCleanup.sh
```
* Review output and make sure each region says OK.  If anything FOUND, clean it up manually:
```sh
% bash verifyCleanup.sh
# Account:****  Arn:arn:aws:iam::****:user/eruser315
Region      Type     ID/Arn                           Name
----------- -------- ------------------------------- -----------------------------
us-east-1   OK
us-east-2   OK
eu-central-1 OK
eu-west-1   OK
```
* Example of an UNEXPECTED (BAD) resource found:
```sh
% bash verifyCleanup.sh
# Account:****  Arn:arn:aws:iam::****:user/eruser315
Region      Type     ID/Arn                           Name
----------- -------- ------------------------------- -----------------------------
us-east-1   EC2      i-0e850b78628ec8472             deploy-jh
us-east-1   EC2      i-088c5153e13a942d2             capstonew1-bastion-0
us-east-1   EC2      i-046d7fa8f7ee5c63b             capstonew1-asg-instance
us-east-1   EC2      i-074be88c7dd9cc395             capstonew1-asg-instance
us-east-1   EC2      i-06eefb2b614dc175d             capstonew1-asg-instance
us-east-1   application arn:aws:elasticloadbalancing:us-east-1:****:loadbalancer/app/capstonew1-alb/06a5bd4e7e9f198f capstonew1-alb
us-east-1   NATGW    nat-007a63045fc247bf6           capstonew1-natgw-0
us-east-1   NATGW    nat-00f4730040e3fbf48           capstonew1-natgw-2
us-east-1   NATGW    nat-094ccca041117d073           capstonew1-natgw-1
us-east-1   VPC      vpc-0908da3291f910626           capstonew1-vpc
us-east-1   FOUND
us-east-2   OK
eu-central-1 OK
eu-west-1   OK
```
