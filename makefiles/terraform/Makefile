CWD=$(shell pwd)

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

tfmoto-before-%:
	cp infrastructure/moto/override.tf infrastructure/aws/$*/main_override.tf

tfmoto-teardown-%:
	rm infrastructure/aws/$*/main_override.tf

tfmoto-init-%:
	@echo "Initializing Terraform $*"
	terraform -chdir=infrastructure/aws/$* init \

tfmoto-validate-%:
	@echo "Validating Terraform $*"
	terraform -chdir=infrastructure/aws/$* validate \

tfmoto-apply-%:
	@echo "Applying Terraform $*"
	terraform -chdir=infrastructure/aws/$* apply --auto-approve \
	-state=$(CWD)/tfmoto/$*/.terraform.tfstate \
	-state-out=$(CWD)/tfmoto/$*/.terraform.tfstate \
	-backup=-

tfmoto-destroy-%:
	terraform -chdir=infrastructure/aws/$* destroy --auto-approve \
	-state=$(CWD)/tfmoto/$*/.terraform.tfstate \
	-state-out=$(CWD)/tfmoto/$*/.terraform.tfstate \
	-backup=-

tfmoto-output-%:
	terraform -chdir=infrastructure/aws/$* output \
	-state=$(CWD)/tfmoto/$*/.terraform.tfstate \


tfl-init-%: tfmoto-before-% tfmoto-init-% tfmoto-teardown-%
	@echo "Init completed for $*"

tfl-validate-%: tfmoto-before-% tfmoto-validate-% tfmoto-teardown-%
	@echo "Validate completed for $*"

tfl-apply-%: tfmoto-before-% tfmoto-apply-% tfmoto-teardown-%
	@echo "Apply completed for $*"

tfl-destroy-%: tfmoto-before-% tfmoto-destroy-% tfmoto-teardown-%
	@echo "Destroy completed for $*"

tfl-output-%: tfmoto-before-% tfmoto-output-% tfmoto-teardown-%
	@echo "Output completed for $*"
