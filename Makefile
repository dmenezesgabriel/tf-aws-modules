ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
REGION=us-east-1
REPO_HELLOWORLD1=$(shell aws ecr describe-repositories --repository-names helloworld1 --region $(REGION) --query "repositories[0].repositoryUri" --output text)
REPO_HELLOWORLD2=$(shell aws ecr describe-repositories --repository-names helloworld2 --region $(REGION) --query "repositories[0].repositoryUri" --output text)

.PHONY: build push login test-dns

login:
	@echo "Logging in to ECR..."
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

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
	docker push $(REPO_HELLOWORLD1):latest
	docker push $(REPO_HELLOWORLD2):latest

test-dns:
	@echo "Testing DNS resolution for ECR endpoint..."
	ping -c 1 $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com || (echo "DNS resolution failed"; exit 1)
