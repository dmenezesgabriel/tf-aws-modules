#!/bin/bash

aws ssm put-parameter --name "/app1_name" --value "App1" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/app2_name" --value "App2" --type String --region us-east-1 --endpoint-url http://localhost:4566

