apply-batch-command-migrations:
	aws batch submit-job \
	--job-name alembic-migration-job \
	--job-queue todo-microservices-batch-command-alembic-migration-job-queue \
	--job-definition todo-microservices-command-alembic-migration-batch-job-definition
