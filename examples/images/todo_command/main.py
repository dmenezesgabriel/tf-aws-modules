import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from src.adapter.http_api import HTTPApiAdapter
from src.adapter.postgres import PostgresTodoAdapter
from src.config import get_config
from src.domain.services import TodoService

config = get_config()
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    postgres_adapter = PostgresTodoAdapter()
    todo_service = TodoService(todo_repository=postgres_adapter)
    http_api_adapter = HTTPApiAdapter(todo_service=todo_service)
    app.include_router(http_api_adapter.router, prefix=config.APP_PATH)
    yield


app = FastAPI(
    lifespan=lifespan,
    docs_url=config.APP_PATH + "/docs",
    openapi_url=config.APP_PATH + "/openapi.json",
)
