ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
REGION=us-east-1
RETRIES=3
SLEEP_SECONDS=1

REPO_HELLOWORLD1=$(shell aws ecr describe-repositories --repository-names helloworld1 --region $(REGION) --query "repositories[0].repositoryUri" --output text)
REPO_HELLOWORLD2=$(shell aws ecr describe-repositories --repository-names helloworld2 --region $(REGION) --query "repositories[0].repositoryUri" --output text)

.PHONY: build push login test-dns force-deploy

login:
	@echo "Logging in to ECR..."
	@set -e; \
	for i in $$(seq 1 $(RETRIES)); do \
		aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com && break || (echo "Retry $$i/$$(($(RETRIES))) failed. Retrying after $(SLEEP_SECONDS) seconds..."; sleep $(SLEEP_SECONDS)); \
	done

build:
	@echo "Building Docker images..."
	docker build -t helloworld1 ./helloworld1
	docker build -t helloworld2 ./helloworld2

tag:
	@echo "Tagging Docker images..."
	docker tag helloworld1:latest $(REPO_HELLOWORLD1):latest
	docker tag helloworld2:latest $(REPO_HELLOWORLD2):latest

push: login build tag
	@echo "Pushing Docker images to ECR..."
	@set -e; \
	for i in $$(seq 1 $(RETRIES)); do \
		docker push $(REPO_HELLOWORLD1):latest && docker push $(REPO_HELLOWORLD2):latest && break || (echo "Retry $$i/$$(($(RETRIES))) failed. Retrying after $(SLEEP_SECONDS) seconds..."; sleep $(SLEEP_SECONDS)); \
	done

force-deploy:
	@echo "Forcing ECS deployment..."
	aws ecs update-service --cluster demo-cluster --service app1 --force-new-deployment && \
	aws ecs update-service --cluster demo-cluster --service app2 --force-new-deployment

test-dns:
	@echo "Testing DNS resolution for ECR endpoint..."
	ping -c 1 $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com || (echo "DNS resolution failed"; exit 1)
