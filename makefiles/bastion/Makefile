PROJECT_NAME = todo-microservices
NAME=main
BASTION_KEY_FILE = /tmp/bastion_key.pem

fetch-parameters:
	@echo "Fetching SSM parameters..."
	$(eval BASTION_IP := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/ec2/bastion/$(NAME)/ec2-bastion-public-ip" --query "Parameter.Value" --output text))
	$(eval RDS_ENDPOINT := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/rds/$(NAME)/postgres/rds_instance_endpoint_url" --query "Parameter.Value" --output text))
	$(eval DOCUMENT_DB_ENDPOINT := $(shell aws ssm get-parameter --name "/$(PROJECT_NAME)/documentdb/$(NAME)/documentdb_endpoint" --query "Parameter.Value" --output text))
	@echo "Parameters fetched."

store-bastion-key:
	@echo "Storing bastion key in a temporary file..."
	@aws ssm get-parameter --name "/$(PROJECT_NAME)/ec2/bastion/$(NAME)/ec2-bastion-host-private-key" --query "Parameter.Value" --output text > $(BASTION_KEY_FILE)
	@chmod 600 $(BASTION_KEY_FILE)
	@echo "Bastion key stored."

cleanup-bastion-key:
	@echo "Cleaning up temporary files..."
	@rm -f $(BASTION_KEY_FILE)
	@echo "Temporary files cleaned."

ssh-bastion: fetch-parameters store-bastion-key
	ssh -i $(BASTION_KEY_FILE) -p 22 ec2-user@$(BASTION_IP)

execute-rds-portforward:
	@echo "Executing SSH command..."
	ssh -i $(BASTION_KEY_FILE) -f -N -L 5432:$(RDS_ENDPOINT) -p 22 ec2-user@$(BASTION_IP) -v
	@echo "SSH command executed."

execute-documentdb-portforward:
	@echo "Executing SSH command..."
	ssh -i $(BASTION_KEY_FILE) -f -N -L 27017:$(DOCUMENT_DB_ENDPOINT):27017 -p 22 ec2-user@$(BASTION_IP) -v
	@echo "SSH command executed."

stop-rds-portforward:
	lsof -ti:5432 | xargs kill -9

stop-documentdb-portforward:
	lsof -ti:27017 | xargs kill -9

%-portforward: fetch-parameters store-bastion-key execute-$*-portforward
