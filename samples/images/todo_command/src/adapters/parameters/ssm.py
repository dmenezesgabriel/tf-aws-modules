import logging
from typing import Optional

from botocore.exceptions import ClientError  # type: ignore

from src.adapters.cloud.aws.client import AWSClientAdapter
from src.adapters.exceptions import ParameterNotFound, ParameterStoreException
from src.ports.parameter_store import ParameterStoreInterface
from src.utils.resources import Resource

logger = logging.getLogger()


class SSMParameterStoreAdapter(AWSClientAdapter, ParameterStoreInterface):
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
        resource = Resource()
        parameters = resource.load_json("parameters.json")
        return self.__get_parameter(parameters["ssm"][name])
