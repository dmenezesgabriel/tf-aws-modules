import logging

from fastapi import FastAPI
from src.adapter.cognito import AWSCognitoAdapter
from src.adapter.http_api import HTTPApiAdapter
from src.config import get_config
from src.domain.services import AuthService

config = get_config()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


app = FastAPI(
    docs_url=config.APP_PATH + "/docs",
    openapi_url=config.APP_PATH + "/openapi.json",
)


@app.on_event("startup")
async def startup_event():
    cognito_adapter = AWSCognitoAdapter()
    auth_service = AuthService(auth_adapter=cognito_adapter)
    http_api = HTTPApiAdapter(auth_service=auth_service)
    app.include_router(http_api.router, prefix=config.APP_PATH)
