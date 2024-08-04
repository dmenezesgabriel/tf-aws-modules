import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI

from src.adapters.database.postgres.todo import PostgresTodoAdapter
from src.adapters.http.fastapi.api import HTTPApiAdapter
from src.adapters.publisher.pika import PikaAdapter
from src.config import get_config
from src.domain.services.todo import TodoService

config = get_config()
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    postgres_adapter = PostgresTodoAdapter()
    pika_adapter = PikaAdapter()
    todo_service = TodoService(
        todo_repository=postgres_adapter, event_publisher=pika_adapter
    )
    http_api_adapter = HTTPApiAdapter(todo_service=todo_service)
    app.include_router(http_api_adapter.router, prefix=config.APP_PATH)
    yield


app = FastAPI(
    lifespan=lifespan,
    docs_url=config.APP_PATH + "/docs",
    openapi_url=config.APP_PATH + "/openapi.json",
)
