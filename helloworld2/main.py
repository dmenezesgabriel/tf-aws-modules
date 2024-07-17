import logging
import os

import boto3  # type: ignore
from fastapi import APIRouter, FastAPI

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Config:
    APP_PREFIX = "/app2"
    AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
    AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
    AWS_ENDPOINT_URL = os.getenv("AWS_ENDPOINT_URL")
    AWS_REGION_NAME = os.getenv("AWS_REGION_NAME", "us-east-1")


app = FastAPI(
    docs_url=Config.APP_PREFIX + "/docs",
    openapi_url=Config.APP_PREFIX + "/openapi.json",
)
router = APIRouter()

aws_access_key_id = Config.AWS_ACCESS_KEY_ID
aws_secret_access_key = Config.AWS_SECRET_ACCESS_KEY
if not Config.AWS_ENDPOINT_URL:
    session = boto3.Session()
    credentials = session.get_credentials()
    aws_access_key_id = credentials.access_key
    aws_secret_access_key = credentials.secret_key

try:
    ssm_client = boto3.client(
        "ssm",
        endpoint_url=Config.AWS_ENDPOINT_URL,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        region_name=Config.AWS_REGION_NAME,
    )
    logger.info("SSM client connected successfully.")
except Exception as e:
    logger.error(f"Failed to create SSM client: {e}")
    raise


@router.get("/")
def read_root():
    try:
        app_name = ssm_client.get_parameter(
            Name="/app2_name",
            WithDecryption=True,
        )["Parameter"]["Value"]
        logger.info("Retrieved parameter /app1_name successfully.")
        return {"message": f"Hello World from {app_name}"}
    except Exception as e:
        logger.error(f"Failed to retrieve parameter /app1_name: {e}")
        raise


app.include_router(router, prefix=Config.APP_PREFIX)
