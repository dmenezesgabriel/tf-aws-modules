import logging

from fastapi import APIRouter, Depends

from src.adapters.http.fastapi.cognito_authorizer import (
    CognitoAuthorizerFactory,
)
from src.common.dto import (
    TodoCreateRequestDTO,
    TodoResponseDTO,
    TodoUpdateRequestDTO,
)
from src.config import get_config
from src.domain.services.todo import TodoService
from src.ports.todo_api import TodoApiPort

config = get_config()
logger = logging.getLogger(__name__)


class FastApiTodoAdapter(TodoApiPort):
    def __init__(self, todo_service: TodoService) -> None:
        self.dependencies = (
            [Depends(CognitoAuthorizerFactory().get("access_token"))]
            if config.ENVIRONMENT == "production"
            else None
        )
        self.__todo_service = todo_service
        self.router = APIRouter()
        self.router.add_api_route(
            "/todo",
            self.create_todo,
            methods=["POST"],
            dependencies=self.dependencies,
        )
        self.router.add_api_route(
            "/todo/{id}",
            self.get_todo_by_id,
            methods=["GET"],
            dependencies=self.dependencies,
        )
        self.router.add_api_route(
            "/todo/{id}",
            self.update_todo,
            methods=["PUT"],
            dependencies=self.dependencies,
        )
        self.router.add_api_route(
            "/todo/{id}",
            self.delete_todo,
            methods=["DELETE"],
            dependencies=self.dependencies,
        )

    def create_todo(self, todo: TodoCreateRequestDTO) -> TodoResponseDTO:
        try:
            created_todo = self.__todo_service.create_todo(
                title=todo.title,
                description=todo.description,
                done=todo.done,
            )
            return TodoResponseDTO(
                id=created_todo.id,
                title=created_todo.title,
                description=created_todo.description,
                done=created_todo.done,
            )
        except Exception as error:
            logger.error(error)
            raise

    def get_todo_by_id(self, id: str) -> TodoResponseDTO:
        try:
            todo = self.__todo_service.get_todo_by_id(id=id)
            return TodoResponseDTO(
                id=todo.id,
                title=todo.title,
                description=todo.description,
                done=todo.done,
            )
        except Exception as error:
            logger.error(error)
            raise

    def update_todo(
        self, id: str, todo: TodoUpdateRequestDTO
    ) -> TodoResponseDTO:
        try:
            updated_todo = self.__todo_service.update_todo(
                id=id,
                title=todo.title,
                description=todo.description,
                done=todo.done,
            )
            return TodoResponseDTO(
                id=updated_todo.id,
                title=updated_todo.title,
                description=updated_todo.description,
                done=updated_todo.done,
            )
        except Exception as error:
            logger.error(error)
            raise

    def delete_todo(self, id: str) -> bool:
        try:
            response = self.__todo_service.delete_todo(id=id)
            return response
        except Exception as error:
            logger.error(error)
            raise
