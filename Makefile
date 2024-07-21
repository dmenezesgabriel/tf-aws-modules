ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
REGION=us-east-1
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

rds-bastion-portforward:
	ssh -i /path/key.pem -f -N -L 5432:<rds-endpoint>:5432 -p 22 ec2-user@<bastion-ip> -v
