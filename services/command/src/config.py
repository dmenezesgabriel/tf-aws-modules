import importlib
import logging
import logging.config
import os
from typing import Optional

from src.utils.singleton import Singleton


class Config(metaclass=Singleton):
    ENVIRONMENT = os.getenv("ENVIRONMENT")
    LOG_LEVEL = "DEBUG"
    APP_PATH = "/command"
    PARAMETER_STORE_MODULE = {
        "path": "src.adapter.environment",
        "class_name": "EnvironmentParameterStoreAdapter",
    }

    def __init__(self):
        self.__configure_logging()
        self.__parameter_store_adapter = self.__load_parameter_store()

    def __configure_logging(self):
        LOGGING = {
            "version": 1,
            "disable_existing_loggers": True,
            "formatters": {
                "standard": {
                    "format": (
                        "[%(asctime)s] %(levelname)s "
                        "[%(filename)s.%(funcName)s:%(lineno)d] "
                        "%(message)s"
                    ),
                    "datefmt": "%Y-%m-%d %H:%M:%S",
                }
            },
            "handlers": {
                "stdout_logger": {
                    "formatter": "standard",
                    "class": "logging.StreamHandler",
                }
            },
            "loggers": {
                "": {  # root
                    "level": self.LOG_LEVEL,
                    "handlers": ["stdout_logger"],
                    "propagate": False,
                }
            },
        }
        logging.config.dictConfig(LOGGING)

    def __load_parameter_store(self):
        module = getattr(
            importlib.import_module(self.PARAMETER_STORE_MODULE["path"]),
            self.PARAMETER_STORE_MODULE["class_name"],
        )
        return module()

    def get_parameter(self, name: str) -> Optional[str]:
        return self.__parameter_store_adapter.get_parameter(name)


class LocalConfig(Config):
    pass


class TestConfig(Config):
    pass


class DevelopmentConfig(Config):
    PARAMETER_STORE_MODULE = {
        "path": "src.adapter.ssm",
        "class_name": "SSMParameterStoreAdapter",
    }


class StagingConfig(Config):
    PARAMETER_STORE_MODULE = {
        "path": "src.adapter.ssm",
        "class_name": "SSMParameterStoreAdapter",
    }


class ProductionConfig(Config):
    LOG_LEVEL = "INFO"
    PARAMETER_STORE_MODULE = {
        "path": "src.adapter.ssm",
        "class_name": "SSMParameterStoreAdapter",
    }


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
