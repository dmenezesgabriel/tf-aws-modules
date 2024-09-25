terraform-%:
	@echo "========================"
	@echo "Run terraform $*"
	@echo "========================"
	@if [ "$*" = "apply" ] || [ "$*" = "destroy" ]; then \
		docker compose run --rm terraform $* --auto-approve; \
	else \
		docker compose run --rm terraform $*; \
	fi

run: terraform-init terraform-validate terraform-apply
	@echo "========================"
	@echo "Run application"
	@echo "========================"
	@docker compose up app
