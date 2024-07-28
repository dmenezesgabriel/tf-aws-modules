ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
REGION=us-east-1

REPO_AUTH_NAME=ecs-todo-auth
REPO_COMMAND_NAME=ecs-todo-command

REPO_AUTH=$(shell aws ecr describe-repositories --repository-names $(REPO_AUTH_NAME) --region $(REGION) --query "repositories[0].repositoryUri" --output text)
REPO_COMMAND=$(shell aws ecr describe-repositories --repository-names $(REPO_COMMAND_NAME) --region $(REGION) --query "repositories[0].repositoryUri" --output text)

TAG_FILE=.tag

RETRIES=100
SLEEP_SECONDS=3

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

build: generate-tag get-tag
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
