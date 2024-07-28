apply-batch-command-migrations:
	aws batch submit-job \
	--job-name alembic-migration-job \
	--job-queue todo-microservices-batch-job-queue \
	--job-definition todo-microservices-batch-job-definition
