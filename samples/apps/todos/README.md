# Todo App

This is the _Command_ part of a sample CQRS Todo App using Ports and Adapters software architecture.

## Development

1. Database

```sh
docker compose up -d postgres
```

2. (Optional) Create a migration:

```sh
make add migration
```

3. Migrations

```sh
make apply-migrations
```

4. Broker

```sh
docker compose up -d rabbitmq
```

5. App

```sh
docker compose up app
```

6. Access app url:

http://localhost:8000/command/docs

7. Access broker dashboard url:

http://localhost:15672

## Development

1. Tests

```sh
make unit-tests
```

2. Allure Reports

```sh
make allure
```

3. Go to Allure dashboard url:

http://localhost:35741

## Useful

Nice Chat GPT prompt for tests:

```txt
create unit tests using unittest package only in python correctly mocking whatever is necessary with a nice coverage using triple A method:
<code>
```
