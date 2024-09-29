import logging
import os
from typing import Dict, Optional

from src.adapters.exceptions import ParameterNotFoundException
from src.ports.parameter_store_port import ParameterStorePort

logger = logging.getLogger()


class EnvironmentParameterStoreAdapter(ParameterStorePort):
    def __init__(self, parameter_map: Optional[Dict[str, str]] = None) -> None:
        self.__parameter_map = parameter_map
        logger.info("Initialized Environment parameter store")

    def __get_parameter(self, key: str) -> Optional[str]:
        parameter = os.getenv(key)
        if parameter:
            return parameter
        raise ParameterNotFoundException(
            {
                "code": "environment.error.__get_parameter",
                "message": "Parameter not found",
            }
        )

    def get_parameter(self, name: str) -> Optional[str]:
        if not self.__parameter_map:
            return self.__get_parameter(name)
        return self.__get_parameter(self.__parameter_map[name])
