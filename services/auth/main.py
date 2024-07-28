import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from src.adapter.cognito import AWSCognitoAdapter
from src.adapter.http_api import HTTPApiAdapter
from src.config import get_config
from src.domain.services import AuthService

config = get_config()
logger = logging.getLogger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    cognito_adapter = AWSCognitoAdapter()
    auth_service = AuthService(auth_adapter=cognito_adapter)
    http_api = HTTPApiAdapter(auth_service=auth_service)
    app.include_router(http_api.router, prefix=config.APP_PATH)
    yield


app = FastAPI(
    lifespan=lifespan,
    docs_url=config.APP_PATH + "/docs",
    openapi_url=config.APP_PATH + "/openapi.json",
)
