ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
REGION=us-east-1

PROJECT_NAME = todo-microsservices

BASTION_KEY_FILE = /tmp/bastion_key.pem

RETRIES=100
SLEEP_SECONDS=3
TAG_FILE=.tag

REPO_AUTH=$(shell aws ecr describe-repositories --repository-names ecs-todo-auth --region $(REGION) --query "repositories[0].repositoryUri" --output text)
REPO_COMMAND=$(shell aws ecr describe-repositories --repository-names ecs-todo-command --region $(REGION) --query "repositories[0].repositoryUri" --output text)

.PHONY: build push login terraform-apply

generate-tag:
	@echo "Generating tag..."
	@date +%Y%m%d%H%M%S > $(TAG_FILE)

get-tag:
	@echo "Fetching tag..."
	@cat $(TAG_FILE)

login:
	@echo "Logging in to ECR..."
	@set -e; \
	for i in $$(seq 1 $(RETRIES)); do \
		aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com && break || (echo "Retry $$i/$$(($(RETRIES))) failed. Retrying after $(SLEEP_SECONDS) seconds..."; sleep $(SLEEP_SECONDS)); \
	done

build: get-tag
	@echo "Building Docker images..."
	docker build -t ecs-todo-auth:$(shell cat $(TAG_FILE)) ./services/auth
	docker build -t ecs-todo-command:$(shell cat $(TAG_FILE)) ./services/command

tag: get-tag
	@echo "Tagging Docker images..."
	docker tag ecs-todo-auth:$(shell cat $(TAG_FILE)) $(REPO_AUTH):$(shell cat $(TAG_FILE))
	docker tag ecs-todo-command:$(shell cat $(TAG_FILE)) $(REPO_COMMAND):$(shell cat $(TAG_FILE))

push: login build tag
	@echo "Pushing Docker images to ECR..."
	@set -e; \
	for i in $$(seq 1 $(RETRIES)); do \
		docker push $(REPO_AUTH):$(shell cat $(TAG_FILE)) && \
		docker push $(REPO_COMMAND):$(shell cat $(TAG_FILE)) && \
		break || (echo "Retry $$i/$$(($(RETRIES))) failed. Retrying after $(SLEEP_SECONDS) seconds..."; sleep $(SLEEP_SECONDS)); \
	done

terraform-apply: get-tag
	@echo "Applying Terraform with image tag $(shell cat $(TAG_FILE))..."
	export TF_VAR_image_tag=$(shell cat $(TAG_FILE)); terraform -chdir=infrastructure/aws apply -var="image_tag=$(shell cat $(TAG_FILE))" --auto-approve

terraform-destroy: get-tag
	@echo "Applying Terraform with image tag $(shell cat $(TAG_FILE))..."
	export TF_VAR_image_tag=$(shell cat $(TAG_FILE)); terraform -chdir=infrastructure/aws destroy -var="image_tag=$(shell cat $(TAG_FILE))" --auto-approve

fetch-parameters:
	@echo "Fetching SSM parameters..."
	$(eval BASTION_IP := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/ec2/bastion/ec2-bastion-public-ip" --query "Parameter.Value" --output text))
	$(eval RDS_ENDPOINT := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/rds/postgres/endpoint_url" --query "Parameter.Value" --output text))
	@echo "Parameters fetched."

store-bastion-key:
	@echo "Storing bastion key in a temporary file..."
	@aws ssm get-parameter --name "/$(PROJECT_NAME)/ec2/bastion/ec2-bastion-host-private-key" --query "Parameter.Value" --output text > $(BASTION_KEY_FILE)
	@chmod 600 $(BASTION_KEY_FILE)
	@echo "Bastion key stored."

execute-ssh:
	@echo "Executing SSH command..."
	ssh -i $(BASTION_KEY_FILE) -f -N -L 5432:$(RDS_ENDPOINT) -p 22 ec2-user@$(BASTION_IP) -v
	@echo "SSH command executed."

cleanup-bastion-key:
	@echo "Cleaning up temporary files..."
	@rm -f $(BASTION_KEY_FILE)
	@echo "Temporary files cleaned."

rds-portforward: fetch-parameters store-bastion-key execute-ssh

create-command-migration:
	@read -p "Enter migration message: " MESSAGE; \
	docker compose run --rm command-migrations /bin/bash -c \
	"alembic -c migrations/alembic/alembic.ini revision --autogenerate -m '$$MESSAGE'"

apply-command-migrations:
	docker compose run --rm command-migrations

terraform-init-%:
	@echo "Initializing Terraform $*"
	terraform -chdir=infrastructure/aws/$* init

terraform-validate-%:
	@echo "Validating Terraform $*"
	terraform -chdir=infrastructure/aws/$* validate

terraform-apply-%:
	@echo "Applying Terraform $*"
	@set -e; \
	for i in $$(seq 1 $(RETRIES)); do \
		terraform -chdir=infrastructure/aws/$* apply --auto-approve && \
		break || (echo "Retry $$i/$$(($(RETRIES))) failed. Retrying after $(SLEEP_SECONDS) seconds..."; sleep $(SLEEP_SECONDS)); \
	done

terraform-destroy-%:
	@echo "Destroying Terraform $*"
	terraform -chdir=infrastructure/aws d/$*estroy --auto-approve

terraform-destroy-all: terraform-destroy-bastion terraform-destroy-job terraform-destroy-ecs terraform-destroy-cognito terraform-destroy-rds terraform-destroy-vpc
