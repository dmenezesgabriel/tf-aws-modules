add-migration:
	@read -p "Enter migration message: " MESSAGE; \
	docker compose run --rm app /bin/bash -c \
	"alembic -c migrations/alembic/alembic.ini revision --autogenerate -m '$$MESSAGE'"

apply-migrations:
	docker compose run --rm app /bin/bash -c \
	"alembic -c migrations/alembic/alembic.ini upgrade head"
