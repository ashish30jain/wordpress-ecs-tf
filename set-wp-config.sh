#!/bin/bash
password=$(aws ssm get-parameter --name "mysql_password" --output text --query Parameter.Value --region=$AWS_REGION)
sed -i 's/mysql_password/$password/g' wordpress/wp-config.php
sed -i 's/mysql_host/$DATABASE_HOST' wordpress/wp-config.php