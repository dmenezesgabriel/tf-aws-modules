import logging
import logging.config
import os
from typing import Optional, cast

from src.ports.parameter_store_port import ParameterStorePort
from src.utils.module import Module, Modules
from src.utils.resources import Resource
from src.utils.singleton import Singleton

logger = logging.getLogger()


class Config(metaclass=Singleton):
    ENVIRONMENT = os.getenv("ENVIRONMENT")
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    APP_PATH = os.getenv("APP_PATH", "/auth")
    PARAMETER_STORE_MODULE = os.getenv(
        "PARAMETER_STORE_MODULE", Module.SSM_PARAMETER_STORE.value
    )

    def __init__(self) -> None:
        self.__configure_logging()
        self.__parameter_store_adapter = self.__load_parameter_store()

    def __configure_logging(self) -> None:
        logger_config = Resource.load_json("logger.json")
        logging.config.dictConfig(logger_config)
        logging.getLogger().setLevel(getattr(logging, self.LOG_LEVEL))

    def __load_parameter_store(self) -> ParameterStorePort:
        parameters = Resource.load_json("parameters.json")
        parameter_map = parameters[self.PARAMETER_STORE_MODULE]
        return cast(
            ParameterStorePort,
            Modules.get_class_default_instance(
                self.PARAMETER_STORE_MODULE,
                parameter_map=parameter_map,
            ),
        )

    def get_parameter(self, name: str) -> Optional[str]:
        return self.__parameter_store_adapter.get_parameter(name)


class LocalConfig(Config):
    LOG_LEVEL = "INFO"


class TestConfig(Config):
    pass


class DevelopmentConfig(Config):
    pass


class StagingConfig(Config):
    pass


class ProductionConfig(Config):
    LOG_LEVEL = "INFO"


def config_factory(environment: str) -> Config:
    configs = {
        "local": LocalConfig,
        "test": TestConfig,
        "development": DevelopmentConfig,
        "staging": StagingConfig,
        "production": ProductionConfig,
    }
    config_class = configs[environment]
    return config_class()


def get_config() -> Config:
    environment = os.getenv("ENVIRONMENT", "local")
    app_config = config_factory(environment)

    return app_config
