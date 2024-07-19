ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
REGION=us-east-1
RETRIES=100
SLEEP_SECONDS=3
TAG_FILE=.tag

REPO_HELLOWORLD1=$(shell aws ecr describe-repositories --repository-names helloworld1 --region $(REGION) --query "repositories[0].repositoryUri" --output text)
REPO_HELLOWORLD2=$(shell aws ecr describe-repositories --repository-names helloworld2 --region $(REGION) --query "repositories[0].repositoryUri" --output text)

.PHONY: build push login test-dns force-deploy terraform-apply

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
	docker build -t helloworld1:$(shell cat $(TAG_FILE)) ./helloworld1
	docker build -t helloworld2:$(shell cat $(TAG_FILE)) ./helloworld2

tag: get-tag
	@echo "Tagging Docker images..."
	docker tag helloworld1:$(shell cat $(TAG_FILE)) $(REPO_HELLOWORLD1):$(shell cat $(TAG_FILE))
	docker tag helloworld2:$(shell cat $(TAG_FILE)) $(REPO_HELLOWORLD2):$(shell cat $(TAG_FILE))

push: login build tag
	@echo "Pushing Docker images to ECR..."
	@set -e; \
	for i in $$(seq 1 $(RETRIES)); do \
		docker push $(REPO_HELLOWORLD1):$(shell cat $(TAG_FILE)) && docker push $(REPO_HELLOWORLD2):$(shell cat $(TAG_FILE)) && break || (echo "Retry $$i/$$(($(RETRIES))) failed. Retrying after $(SLEEP_SECONDS) seconds..."; sleep $(SLEEP_SECONDS)); \
	done

force-deploy:
	@echo "Forcing ECS deployment..."
	aws ecs update-service --cluster demo-cluster --service app1 --force-new-deployment && \
	aws ecs update-service --cluster demo-cluster --service app2 --force-new-deployment

terraform-apply: get-tag
	@echo "Applying Terraform with image tag $(shell cat $(TAG_FILE))..."
	export TF_VAR_image_tag=$(shell cat $(TAG_FILE)); terraform -chdir=infrastructure/aws apply -var="image_tag=$(shell cat $(TAG_FILE))" --auto-approve

terraform-destroy: get-tag
	@echo "Applying Terraform with image tag $(shell cat $(TAG_FILE))..."
	export TF_VAR_image_tag=$(shell cat $(TAG_FILE)); terraform -chdir=infrastructure/aws destroy -var="image_tag=$(shell cat $(TAG_FILE))" --auto-approve

test-dns:
	@echo "Testing DNS resolution for ECR endpoint..."
	ping -c 1 $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com || (echo "DNS resolution failed"; exit 1)
