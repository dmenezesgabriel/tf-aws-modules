from abc import ABC, abstractmethod

from src.domain.entities.todo import Todo

class TodoRepository(ABC):
    @abstractmethod
    def create_todo(self, todo: Todo) -> Todo:
        raise NotImplementedError

    def get_todo_by_id(self, id: str) -> Todo:
        raise NotImplementedError

    def update_todo(self, todo: Todo) -> Todo:
        raise NotImplementedError

    def delete_todo(self, id: str) -> bool:
        raise NotImplementedError
