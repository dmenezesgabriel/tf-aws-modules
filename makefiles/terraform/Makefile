tf-init-%:
	@echo "Initializing Terraform $*"
	terraform -chdir=infrastructure/aws/$* init

tf-validate-%:
	@echo "Validating Terraform $*"
	terraform -chdir=infrastructure/aws/$* validate

tf-apply-%:
	terraform -chdir=infrastructure/aws/$* apply --auto-approve

tf-destroy-%:
	terraform -chdir=infrastructure/aws/$* destroy --auto-approve

tf-output-%:
	terraform -chdir=infrastructure/aws/$* output
