#!/bin/bash
password=$(aws ssm get-parameters-by-path --path "/wpdemo/database/password/master/" --output text --query Parameter.Value --region=$AWS_REGION)
sed -i 's/mysql_password/$password/g' wordpress/wp-config.php
sed -i 's/mysql_host/$DATABASE_HOST' wordpress/wp-config.php