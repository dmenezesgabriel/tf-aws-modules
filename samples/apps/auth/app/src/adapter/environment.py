import logging
import os
from typing import Optional

from src.adapter.exceptions import ParameterNotFound
from src.port.parameter_store import ParameterStoreInterface

logger = logging.getLogger()


class EnvironmentParameterStoreAdapter(ParameterStoreInterface):
    PARAMETER_MAPPING = {
        "AWS_COGNITO_USER_POOL_ID": "AWS_COGNITO_USER_POOL_ID",
        "AWS_COGNITO_APP_CLIENT_ID": "AWS_COGNITO_APP_CLIENT_ID",
    }

    def __init__(self):
        logger.info("Initialized Environment parameter store")

    def __get_parameter(self, key: str) -> Optional[str]:
        parameter = os.getenv(key)
        if parameter:
            return parameter
        raise ParameterNotFound(
            {
                "code": "environment.error.__get_parameter",
                "message": "Parameter not found",
            }
        )

    def get_parameter(self, name: str) -> Optional[str]:
        return self.__get_parameter(self.PARAMETER_MAPPING[name])
