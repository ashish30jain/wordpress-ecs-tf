#!/bin/bash
# docker.sh: push and deploy containers
PROGNAME=$(basename $0)
echo $PROGNAME

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
ls -la
OUTPUT_DIR=`pwd`


echo "Get commit hash for the code you want to promote."
codeHash=$(git rev-parse HEAD)

echo "$0 parameters: codeHash=[$codeHash] CONTAINER_IMAGE=[$CONTAINER_IMAGE] MGMT_AWS_ACCESS_KEY_ID=[REDACTED] MGMT_AWS_SECRET_ACCESS_KEY=[REDACTED]"

# parameter validation
if [ -z "$codeHash" ] || [ -z "$MGMT_AWS_ACCESS_KEY_ID" ] || [ -z "$MGMT_AWS_SECRET_ACCESS_KEY" ] || [ -z "$CONTAINER_IMAGE" ]; then
   echo "Invalid parameters.  Usage:"
   echo "$0 [codeHash] [MGMT_AWS_ACCESS_KEY_ID] [MGMT_AWS_SECRET_ACCESS_KEY] [CONTAINER_IMAGE] "
   echo
   echo "Example: "
   echo "$0 ad5135a78fb31be93e9e555b67f8b02a1da0d032  hello-world-proxy  aws-key aws-secret"
   exit 1
fi

echo "Creating AWS provider profile"
mkdir ~/.aws
touch ~/.aws/credentials

if [ $? -ne 0 ]; then
   echo "Error creating directories"
   exit 1
fi

ls -la ~/.aws

echo "Setting AWS creds for MGMT"
echo "[default]" >> ~/.aws/credentials
echo "aws_access_key_id = ${MGMT_AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials |tee
echo "aws_secret_access_key = ${MGMT_AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials |tee

if [ $? -ne 0 ]; then
   echo "Error creating AWS provider profile"
   exit 1
fi


# If exists, pull manifest from ECR and tag remote image
echo "existingSha=$(aws ecr list-images --region us-east-1 --repository-name ${CONTAINER_IMAGE} | grep ${codeHash})"
# existingSha=$(aws ecr list-images --region us-east-1 --repository-name ${CONTAINER_IMAGE} | grep ${codeHash})


# if [ -n "$existingSha" ]; then
      echo "Lets build an artifact"
     CONTAINER_LOCATION="123456789.dkr.ecr.us-east-1.amazonaws.com/demo-wp-ecs"

      echo "Commit hash: $codeHash"
      echo $codeHash > ${OUTPUT_DIR}/code_build/commit.txt

      cp -R source_code/* ${OUTPUT_DIR}/code_build
      if [ $? -ne 0 ]; then
         echo "Error copying directory to code_build"
         exit 1
      fi
      docker build -t $CONTAINER_LOCATION:$codeHash
      echo "lets see what has been copied"
      ls -la ${OUTPUT_DIR}/code_build
      docker push $CONTAINER_LOCATION:$codeHash
      exit 0
# else
#   echo "Error with this commit "
#   echo "Commit hash for deploy: ${codeHash}"
#   exit 2
#
#  fi
