from abc import ABC, abstractmethod
from typing import Optional


class PublisherPort(ABC):
    @abstractmethod
    def publish(
        self, event_type: str, data: dict, headers: Optional[dict] = None
    ) -> None:
        raise NotImplementedError
