import logging
from typing import Optional

from botocore.exceptions import ClientError  # type: ignore

from src.adapters.cloud.aws_client_adapter import AWSClientAdapter
from src.adapters.exceptions import ParameterNotFound, ParameterStoreException
from src.ports.parameter_store_port import ParameterStorePort

logger = logging.getLogger()


class SSMParameterStoreAdapter(AWSClientAdapter, ParameterStorePort):
    def __init__(self, parameter_map: Optional[dict] = None) -> None:
        super().__init__(client_type="ssm")
        self.__parameter_map = parameter_map
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
        if not self.__parameter_map:
            return self.__get_parameter(name)
        return self.__get_parameter(self.__parameter_map[name])
