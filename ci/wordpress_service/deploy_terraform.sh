#!/bin/bash

error_exit()
{

#    ----------------------------------------------------------------
#    Function for exit due to fatal program error
#        Accepts 2 arguments:
#           Recommend first argument be: "$LINENO: Error code: $?"
#            Second argument is an optional string containing descriptive error message
#    ----------------------------------------------------------------


    echo "${PROGNAME}: $1 ${2:-"Unknown Error"}" 1>&2
    exit 1
}

echo "Where are we and whoami"
pwd
ls -la
whoami
TERRAFORM_ENV="dev"
TERRAFORM_PROJECT="demo-wp-ecs"
CONTAINER_LOCATION="123456789.dkr.ecr.us-east-1.amazonaws.com/demo-wp-ecs"
REGION="us-east-1"
commit-id="git-commit-id"
DB_HOST="$TERRAFORMM_PROJECT.$TERRAFORM_ENV.$REGION.amazonaws.com"

echo "##################"
echo "##################"
echo "##################"
echo "##################"

mkdir ~/.aws
touch ~/.aws/config
touch ~/.aws/credentials

if [ $? -ne 0 ]; then
   echo "Error creating directories"
   exit 1
fi

ls -la ~/.aws

echo "Setting AWS creds for ENV"
echo "[default]" >> ~/.aws/credentials
echo "aws_access_key_id = ${ENV_AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials |tee
echo "aws_secret_access_key = ${ENV_AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials |tee

if [ $? -ne 0 ]; then
   echo "Error creating AWS provider profile"
   exit 1
fi

 # Copy in service to deploy

  wkdir=$(pwd)
  echo "Workdir: $wkdir"
  ls .  
  cp ${wkdir}/locals.tf ci/wordpress_service/


  if [ $? -ne 0 ]; then
     echo "Error fetching service configuration"
     exit 1
  fi

  cd ci/wordpress_service
  echo "What is available"
  pwd
  ls -la

  echo "Create git netrc"
  touch ~/.netrc
  echo "machine bitbucket.org" >> ~/.netrc
  echo "login ${GIT_USERNAME}" >> ~/.netrc |tee
  echo "password ${GIT_PASSWORD}" >> ~/.netrc |tee

  echo "[default]" >> ~/.aws/credentials

  echo "aws_access_key_id = ${ENV_AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials | tee
  echo "aws_secret_access_key = ${ENV_AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials |tee

  echo "[profile default]" >> ~/.aws/config
  echo "output = json" >> ~/.aws/config
  echo "region = us-east-1" >> ~/.aws/config

  echo "See backend config"
  ls -la /usr/bin/terraform

  echo "terraform version"
  terraform -v

  terraform init -backend-config="key=${TERRAFORM_PROJECT}/terraform.tfstate"

  if [ $? -ne 0 ]; then
     echo "Error initializing terraform"
     exit 1
  fi
  echo "list terraform workspace"
  terraform workspace list

  echo "[${TERRAFORM_ENV}]" >> ~/.aws/credentials
  echo "aws_access_key_id = ${ENV_AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials | tee
  echo "aws_secret_access_key = ${ENV_AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials | tee

  echo "[profile ${TERRAFORM_ENV}]" >> ~/.aws/config
  echo "output = json" >> ~/.aws/config
  echo "region = ${REGION}" >> ~/.aws/config

  echo "Lets see our AWS local configuration"
  cat ~/.aws/config

  workspace=''
  echo "Select terraform workspace"
  workspace='true'
  terraform workspace select $TERRAFORM_ENV
  if [ $? -ne 0 ]; then
     echo "$TERRAFORM_ENV workspace not available, create one"
     terraform workspace new $TERRAFORM_ENV
     terraform init -backend-config="key=$TERRAFORM_PROJECT/terraform.tfstate" -backend=true
     if [ $? -ne 0 ]; then
        echo "Error selecting workspace terraform."
        workspace='false'
        exit 1
     fi
  fi
  echo "Terraform apply"
  terraform apply -var "container_version=${commit-id}" \
    -var "container_image=${CONTAINER_LOCATION}" \
    -var "workspace=${TERRAFORM_ENV}" \
    -var "project=${TERRAFORM_PROJECT}" \
    -var "aws_region=${REGION}" \
    -var "database_host=${DB_HOST}" \
    -auto-approve \
    -lock=true

  if [ $? -ne 0 ]; then
      echo "Error pushing to terraform"
      exit 1
  fi
