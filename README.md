# Terraform aws ecs cluster

This is another TODO app example, but using microservices.

- It uses python and FastApi for each microservice built upon Ports and Adapters architecture
- It has a SQL database (PostgreSQL)
- It also has also a NoSQL database (MongoDB)
- The services communicate using queues

## Usage

There is a directory with Makefiles for specific purposes, but they all can be called by a Makefile at the root directory of this project.

### Local Development

_The authentication service is based on Cognito, as localstack does not provide a free tier of it, it will not work, is not needed to run it_.

You can execute the command `docker-compose up` then `make apply-dkr-command-migrations``

#### Moto Server

We are using `moto server` to mock aws services, a dashboard can be seen at `http://localhost:5000/moto-api/`.

### Cloud Deploy

First you need to create the ecr repositories `ecs-todo-auth` and `ecs-todo-command` manually. Then run the command `make push`.

Each resource in `infrastructure/aws` can use the following commands with the directory as command suffix. But I recommend to follow an order.

1. vpc
2. cognito, rds and documentdb (in whenever the order you like it)
3. bastion
4. ecs
5. batch

A batch job must be submitted so the alembic migrations are applied to the PostgreSQL database. Tis can be achieved with the command `make apply-batch-command-migrations`. Then just access the **load balancer** url from _ecs_ `terraform` output with the path of the service followed by "docs" like `<load_balancer_url>/auth/docs`.

- **Terraform init**:

```sh
make tf-init-vpc
```

- **Terraform validate**:

```sh
make tf-validate-vpc
```

- **Terraform apply**:

```sh
make tf-apply-vpc
```

- **Terraform output**:

```sh
make tf-output-vpc
```

- **Terraform destroy**:

```sh
make tf-destroy-vpc
```

## Bastion Host

```sh
make ssh-bastion
```

### DocumentDB connection

```sh
mongosh mongodb://username:password@endpoint:27017
```

or

```sh
mongosh --host endpoint:27017 --username username --password password
```

## Resources

- [moto server](https://docs.getmoto.org/en/latest/docs/server_mode.html)
- [aws-ecs-cluster-on-ec2-with-terraform-2023](https://medium.com/@vladkens/aws-ecs-cluster-on-ec2-with-terraform-2023-fdb9f6b7db07)
- [how-to-diagnose-ecs-fargate-task-failing-to-start](https://stackoverflow.com/questions/56229059/how-to-diagnose-ecs-fargate-task-failing-to-start)
- [jwt-authentication-with-fastapi-and-aws-cognito](https://gntrm.medium.com/jwt-authentication-with-fastapi-and-aws-cognito-1333f7f2729e)
- [building-an-authentication-api-with-aws-cognito-and-fastapi](https://timothy.hashnode.dev/building-an-authentication-api-with-aws-cognito-and-fastapi)
- [fastapi-with-aws-cognito](https://github.com/robotlearner001/blog/blob/main/fastapi-with-aws-cognito/)
- [ecs-with-fargate-terraform](https://cs.fyi/guide/ecs-with-fargate-terraform)
- [verifying-a-json-web-token-from-cognito-in-python-and-fastapi](https://www.angelospanag.me/blog/verifying-a-json-web-token-from-cognito-in-python-and-fastapi)
- [low-cost-vpc-amazon-ecs-cluster](https://containersonaws.com/pattern/low-cost-vpc-amazon-ecs-cluster)
- [accessing-amazon-ecs-fargate-containers-using-aws-systems-manager-session-manager](https://dev.to/rumeshsil/interactively-accessing-amazon-ecs-fargate-containers-using-aws-systems-manager-session-manager-and-ecs-exec-34bm)
- [creating-aws-ecs-cluster-of-ec2-instances-with-terraform](https://medium.com/@paweldudzinski/creating-aws-ecs-cluster-of-ec2-instances-with-terraform-893c15d1116)
- [documentdb-terraform](https://radzion.com/blog/documentdb-terraform)
- [aws-sqs-vs-sns-vs-eventbridge](https://medium.com/engenharia-de-dados-ci%C3%AAncia-de-dados-an%C3%A1lise-de/aws-sqs-vs-sns-vs-eventbridge-quando-usar-cada-um-36dfe0c289c9)
- [apigw-vpclink-pvt-alb-terraform](https://serverlessland.com/patterns/apigw-vpclink-pvt-alb-terraform)
- [create-an-api-with-a-private-integration-to-an-aws-ecs-service-with-terraform-iac](https://dev.to/devops4mecode/create-an-api-with-a-private-integration-to-an-aws-ecs-service-with-terraform-iac-3aj4)
- [aws-http-gateway-with-cognito-and-terraform](https://andrewtarry.com/posts/aws-http-gateway-with-cognito-and-terraform/)
- [terraform-modules-101-create-version-and-publish-on-github](https://medium.com/nerd-for-tech/terraform-modules-101-create-version-and-publish-on-github-4455f3673559#f790)
- [ecs-fargate-with-alb-deployment-using-terraform](https://medium.com/the-cloud-journal/ecs-fargate-with-alb-deployment-using-terraform-part-2-5547408be49a)
- [generate-configmap-using-kustomization-but-the-name-in-configmapref-doesnt](https://stackoverflow.com/questions/77606656/generate-configmap-using-kustomization-but-the-name-in-configmapref-doesnt-i)
- [celery-rabbitmq-fastapi-docker](https://blog.devops.dev/celery-rabbitmq-fastapi-docker-842d2b485d33)
- [scaling-celery-rabbitmq-kubernetes](https://learnk8s.io/scaling-celery-rabbitmq-kubernetes)
