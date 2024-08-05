import importlib
import logging
from enum import Enum
from typing import Any, Dict

try:
    from typing_extensions import TypedDict
except Exception:
    from typing import TypedDict

from src.utils.resources import Resource

logger = logging.getLogger()


class ImportModule(TypedDict):
    path: str
    class_name: str


class Module(Enum):
    SSM_PARAMETER_STORE = "ssm"
    ENVIRONMENT_PARAMETER_STORE = "environment"


class Modules:
    @staticmethod
    def get_class_instance(path: str, class_name: str, *args, **kwargs) -> Any:
        try:
            module = getattr(
                importlib.import_module(path),
                class_name,
            )
            return module(*args, **kwargs)
        except Exception as error:
            logger.info(error)

    @classmethod
    def get_class_default_instance(cls, module: Module, *args, **kwargs):
        modules: Dict[str, ImportModule] = Resource.load_json("modules.json")
        import_module: ImportModule = modules[module.value]
        return cls.get_class_instance(
            import_module["path"], import_module["class_name"], *args, **kwargs
        )
