from abc import ABC, abstractmethod

from src.common.dto import (
    TodoCreateRequestDTO,
    TodoResponseDTO,
    TodoUpdateRequestDTO,
)


class TodoApiPort(ABC):
    @abstractmethod
    def create_todo(self, todo: TodoCreateRequestDTO) -> TodoResponseDTO:
        raise NotImplementedError

    def get_todo_by_id(self, id: str) -> TodoResponseDTO:
        raise NotImplementedError

    def update_todo(
        self, id: str, todo: TodoUpdateRequestDTO
    ) -> TodoResponseDTO:
        raise NotImplementedError

    def delete_todo(self, id: str) -> bool:
        raise NotImplementedError
