import logging

from fastapi import APIRouter, FastAPI
from src.adapter.cognito import AWSCognitoAdapter
from src.adapter.http_api import HTTPApiAdapter
from src.config import get_config
from src.domain.services import AuthService

config = get_config()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


app = FastAPI(
    docs_url=config.APP_PREFIX + "/docs",
    openapi_url=config.APP_PREFIX + "/openapi.json",
)


@app.on_event("startup")
async def startup_event():
    cognito_adapter = AWSCognitoAdapter()
    auth_service = AuthService(auth_adapter=cognito_adapter)
    http_api = HTTPApiAdapter(auth_service=auth_service)

    router = APIRouter()

    @router.get("/")
    def read_root():
        try:
            return {"message": f"Hello World from {config.APP_NAME}"}
        except Exception as e:
            logger.error(f"Failed to retrieve parameter /app1_name: {e}")
            return {"message": "Could not access the ssm parameter store"}

    app.include_router(router, prefix=config.APP_PREFIX)
    app.include_router(http_api.router, prefix=config.APP_PREFIX)
