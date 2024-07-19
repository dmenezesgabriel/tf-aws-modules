import logging
import os

import boto3  # type: ignore
from fastapi import APIRouter, FastAPI

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Config:
    APP_PREFIX = "/app1"
    APP_NAME = os.getenv("APP1_NAME")
    AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
    AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
    AWS_SESSION_TOKEN = os.getenv("AWS_SESSION_TOKEN")
    AWS_ENDPOINT_URL = os.getenv("AWS_ENDPOINT_URL")
    AWS_REGION_NAME = os.getenv("AWS_REGION_NAME")
    AWS_COGNITO_APP_CLIENT_ID = os.getenv("AWS_COGNITO_APP_CLIENT_ID")
    AWS_COGNITO_APP_CLIENT_SECRET = os.getenv("AWS_COGNITO_APP_CLIENT_SECRET")
    AWS_COGNITO_USER_POOL_ID = os.getenv("AWS_COGNITO_USER_POOL_ID")


app = FastAPI(
    docs_url=Config.APP_PREFIX + "/docs",
    openapi_url=Config.APP_PREFIX + "/openapi.json",
)
router = APIRouter()

aws_access_key_id = Config.AWS_ACCESS_KEY_ID
aws_secret_access_key = Config.AWS_SECRET_ACCESS_KEY
aws_session_token = Config.AWS_SESSION_TOKEN
if not Config.AWS_ENDPOINT_URL:
    session = boto3.Session()
    credentials = session.get_credentials()
    aws_access_key_id = credentials.access_key
    aws_secret_access_key = credentials.secret_key
    aws_session_token = credentials.token

try:
    s3_client = boto3.client(
        "s3",
        endpoint_url=Config.AWS_ENDPOINT_URL,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        aws_session_token=aws_session_token,
        region_name=Config.AWS_REGION_NAME,
    )
    logger.info("S3 client connected successfully.")
except Exception as e:
    logger.error(f"Failed to create S3 client: {e}")
    raise

try:
    cognito_client = boto3.client(
        "cognito-idp",
        endpoint_url=Config.AWS_ENDPOINT_URL,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        aws_session_token=aws_session_token,
        region_name=Config.AWS_REGION_NAME,
    )
    logger.info("Cognito client connected successfully.")
except Exception as e:
    logger.error(f"Failed to create cognito client: {e}")
    raise


@router.get("/")
def read_root():
    try:
        return {"message": f"Hello World from {Config.APP_NAME}"}
    except Exception as e:
        logger.error(f"Failed to retrieve parameter /app1_name: {e}")
        return {"message": "Could not access the ssm parameter store"}


@router.get("/buckets")
def list_buckets():
    try:
        response = s3_client.list_buckets()
        buckets = [bucket["Name"] for bucket in response["Buckets"]]
        logger.info("Retrieved list of S3 buckets successfully.")
        return {"buckets": buckets}
    except Exception as e:
        logger.error(f"Failed to list S3 buckets: {e}")
        return {"message": "Could not list S3 buckets"}


@router.post("/user")
def check_user_exists(email: str):
    try:
        response = cognito_client.admin_get_user(
            UserPoolId=Config.AWS_COGNITO_USER_POOL_ID, Username=email
        )
        logger.info(f"cognito response: {response}")
        return {"message": response}
    except Exception as e:
        logger.error(f"Failed to check user pool: {e}")
        return {"message": "Could not check user pool"}


app.include_router(router, prefix=Config.APP_PREFIX)
