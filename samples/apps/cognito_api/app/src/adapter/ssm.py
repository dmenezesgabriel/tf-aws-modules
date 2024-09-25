import logging
from typing import Optional

from botocore.exceptions import ClientError  # type: ignore
from src.adapter.aws import AWSClientAdapter
from src.adapter.exceptions import ParameterNotFound, ParameterStoreException
from src.port.parameter_store import ParameterStoreInterface

logger = logging.getLogger()


class SSMParameterStoreAdapter(AWSClientAdapter, ParameterStoreInterface):
    PARAMETER_MAPPING = {
        "AWS_COGNITO_USER_POOL_ID": "/cognito-api/cognito/main/cognito_app_pool_id",
        "AWS_COGNITO_APP_CLIENT_ID": "/cognito-api/cognito/main/cognito_user_pool_client_id",
    }

    def __init__(self, client_type="ssm"):
        super().__init__(client_type=client_type)
        logger.info("Initialized SSM parameter store")

    def __get_parameter(self, name: str) -> Optional[str]:
        try:
            response = self.client.get_parameter(
                Name=name, WithDecryption=True
            )
            return response["Parameter"]["Value"]
        except ClientError as error:
            if error.response["Error"]["Code"] == "ParameterNotFound":
                logger.error(f"Parameter {name} not found.")
                raise ParameterNotFound(
                    {
                        "code": "ssm.error.get_parameter",
                        "message": f"Parameter not found: {error}",
                    }
                )
            raise ParameterStoreException(
                {
                    "code": "ssm.error.get_parameter",
                    "message": f"Parameter store error: {error}",
                }
            )

    def get_parameter(self, name: str) -> Optional[str]:
        return self.__get_parameter(self.PARAMETER_MAPPING[name])
