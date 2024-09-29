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

unit-tests:
	@echo "========================"
	@echo "Run unit tests"
	@echo "========================"
	docker compose -f docker-compose-test.yaml run --rm tests \
	/bin/bash -c \
	"python -m pytest tests/unit \
	-s \
	-x \
	-vv \
	--cov . \
	--cov-report=html:/app/reports/coverage \
	--cov-report=xml:/app/reports/coverage/coverage.xml \
	--alluredir /app/allure-results"

allure:
	@echo "========================"
	@echo "Run Allure dashboard"
	@echo "========================"
	@docker compose -f docker-compose-test.yaml up -d allure

sonar-scan:
	@echo "========================"
	@echo "Run Sonar scan"
	@echo "========================"
	@docker compose -f docker-compose-sonnar.yaml run --rm sonar-scanner
