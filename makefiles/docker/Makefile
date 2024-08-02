PROJECT_NAME=todo-microservices
AWS_ENDPOINT_URL=http://localhost:5000

docker-hub-login:
	@echo "Logging in to Docker Hub"
	docker login registry-1.docker.io

fetch-local-parameters:
	@echo "Fetching Local SSM parameters..."
	$(eval POSTGRES_CONTAINER_NAME := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/rds/postgres/rds_instance_host" --query "Parameter.Value" --output text --endpoint-url=$(AWS_ENDPOINT_URL)))
	$(eval MONGO_CONTAINER_NAME := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/documentdb/documentdb_endpoint" --query "Parameter.Value" --output text --endpoint-url=$(AWS_ENDPOINT_URL)))
	@echo "Parameters fetched."

compose-up-%: fetch-local-parameters
	POSTGRES_CONTAINER_NAME=$(POSTGRES_CONTAINER_NAME) \
	MONGO_CONTAINER_NAME=$(MONGO_CONTAINER_NAME) \
	docker compose up $* -d

create-command-migration:
	@read -p "Enter migration message: " MESSAGE; \
	docker compose run --rm command-migrations /bin/bash -c \
	"alembic -c migrations/alembic/alembic.ini revision --autogenerate -m '$$MESSAGE'"

apply-dkr-command-migrations`:
	docker compose run --rm command-migrations

