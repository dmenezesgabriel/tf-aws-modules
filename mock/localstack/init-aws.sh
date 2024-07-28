#!/bin/bash
PROJECT_NAME = todo-microservices

# SSM Parameter Store
aws ssm put-parameter --name "/$(PROJECT_NAME)/cognito/cognito_app_client_id" --value "test" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/cognito/cognito_app_pool_id" --value "test" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/documentdb/documentdb_user" --value "mongo" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/documentdb/documentdb_password" --value "mongo" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/documentdb/documentdb_endpoint" --value "mongo" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/documentdb/documentdb_port" --value "27017" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/rds/postgres/rds_instance_host" --value "postgres" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/rds/postgres/rds_instance_port" --value "5432" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/rds/postgres/rds_instance_db_name" --value "postgres" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/rds/postgres/rds_instance_user" --value "postgres" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/rds/postgres/rds_instance_password" --value "postgres" --type String --region us-east-1 --endpoint-url http://localhost:4566
aws ssm put-parameter --name "/$(PROJECT_NAME)/sqs/queue/todo-queue-name" --value "todo-queue" --type String --region us-east-1 --endpoint-url http://localhost:4566

# SQS
aws sqs create-queue --queue-name todo-queue --region us-east-1 --endpoint-url http://localhost:4566
