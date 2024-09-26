import logging
from typing import Optional

from src.config import get_config
from src.domain.entities.todo import Todo

config = get_config()
logger = logging.getLogger(__name__)


class TodoService:
    def __init__(self, todo_repository, event_publisher) -> None:
        self.__todo_repository = todo_repository
        self.__event_publisher = event_publisher

    def create_todo(self, title: str, description: str, done: bool) -> Todo:
        try:
            todo = Todo(title=title, description=description, done=done)
            created_todo = self.__todo_repository.create_todo(todo=todo)
            self.__event_publisher.publish("todo_created", {})
            return created_todo
        except Exception as error:
            logger.error(error)
            raise

    def get_todo_by_id(self, id: str) -> Todo:
        try:
            todo = self.__todo_repository.get_todo_by_id(id=id)
            return todo
        except Exception as error:
            logger.error(error)
            raise

    def update_todo(
        self,
        id: str,
        title: Optional[str] = None,
        description: Optional[str] = None,
        done: Optional[bool] = None,
    ) -> Todo:
        try:
            existing_todo = self.get_todo_by_id(id=id)

            new_title = existing_todo.title
            new_description = existing_todo.description
            new_done = existing_todo.done

            if title is not None:
                new_title = title
            if description is not None:
                new_description = description
            if done is not None:
                new_done = done

            todo = Todo(
                id=id,
                title=new_title,
                description=new_description,
                done=new_done,
            )

            updated_todo = self.__todo_repository.update_todo(todo=todo)
            return updated_todo
        except Exception as error:
            logger.error(error)
            raise

    def delete_todo(self, id: str) -> bool:
        try:
            response = self.__todo_repository.delete_todo(id=id)
            return response
        except Exception as error:
            logger.error(error)
            raise
