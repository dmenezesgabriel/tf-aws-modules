unit-tests:
	@echo "========================"
	@echo "Run unit tests"
	@echo "========================"
	python -m pytest tests/ \
	-s \
	-x \
	-vv \
	--color=yes \
	--cov=src \
	--cov-report=html:reports/coverage \
	--cov-report=xml:reports/coverage/coverage.xml \
	--cov-report=term-missing
