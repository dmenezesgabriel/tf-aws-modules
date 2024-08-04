import logging
import os
from typing import Optional

from src.adapters.exceptions import ParameterNotFound
from src.ports.parameter_store import ParameterStoreInterface
from src.utils.resources import Resource

logger = logging.getLogger()


class EnvironmentParameterStoreAdapter(ParameterStoreInterface):
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
        resource = Resource()
        parameters = resource.load_json("parameters.json")
        return self.__get_parameter(parameters["environment"][name])
