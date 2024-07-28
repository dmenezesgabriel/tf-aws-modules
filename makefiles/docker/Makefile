PROJECT_NAME = todo-microservices

TF_CMD=terraform
AWS_ENDPOINT_URL=http://localhost:5000
LOCALSTACK_HOSTNAME=localhost
EDGE_PORT=5000
S3_HOSTNAME=s3.localhost.motoserver.cloud
COGNITO_IDP_ENDPOINT=http://example.com
AWS_DEFAULT_REGION=us-east-1
CWD=$(shell pwd)

fetch-local-parameters:
	@echo "Fetching Local SSM parameters..."
	$(eval POSTGRES_CONTAINER_NAME := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/rds/postgres/rds_instance_host" --query "Parameter.Value" --output text --endpoint-url=$(AWS_ENDPOINT_URL)))
	$(eval MONGO_CONTAINER_NAME := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/documentdb/documentdb_endpoint" --query "Parameter.Value" --output text --endpoint-url=$(AWS_ENDPOINT_URL)))
	@echo "Parameters fetched."

compose-up-%: fetch-local-parameters
	POSTGRES_CONTAINER_NAME=$(POSTGRES_CONTAINER_NAME) \
	MONGO_CONTAINER_NAME=$(MONGO_CONTAINER_NAME) \
	docker compose up $* -d

tflocal-init-%:
	@echo "Initializing Terraform $*"
	tflocal -chdir=infrastructure/aws/$* init \

tflocal-validate-%:
	@echo "Validating Terraform $*"
	tflocal -chdir=infrastructure/aws/$* validate \

tflocal-apply-%:
	echo "$(CWD)"
	tflocal -chdir=infrastructure/aws/$* apply --auto-approve \
	-state=$(CWD)/tflocal/$*/.terraform.tfstate \
	-state-out=$(CWD)/tflocal/$*/.terraform.tfstate \
	-backup=-

tflocal-destroy-%:
	tflocal -chdir=infrastructure/aws/$* destroy --auto-approve \
	-state=$(CWD)/tflocal/$*/.terraform.tfstate \
	-state-out=$(CWD)/tflocal/$*/.terraform.tfstate \
	-backup=-

tflocal-output-%:
	tflocal -chdir=infrastructure/aws/$* output \

create-command-migration:
	@read -p "Enter migration message: " MESSAGE; \
	docker compose run --rm command-migrations /bin/bash -c \
	"alembic -c migrations/alembic/alembic.ini revision --autogenerate -m '$$MESSAGE'"

apply-dkr-command-migrations`:
	docker compose run --rm command-migrations
