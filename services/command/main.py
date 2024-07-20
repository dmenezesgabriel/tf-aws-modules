import logging

from fastapi import APIRouter, Depends, FastAPI
from src.adapter.aws import AWSClientAdapter
from src.adapter.cognito_authorizer import cognito_jwt_authorizer_access_token
from src.config import get_config

config = get_config()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


app = FastAPI(
    docs_url=config.APP_PATH + "/docs",
    openapi_url=config.APP_PATH + "/openapi.json",
)
router = APIRouter()


class AWSS3Adapter(AWSClientAdapter):
    def __init__(self, client_type="s3"):
        super().__init__(client_type=client_type)


aws_s3_adapter = AWSS3Adapter()


@router.get(
    "/buckets", dependencies=[Depends(cognito_jwt_authorizer_access_token)]
)
def list_buckets():
    try:
        response = aws_s3_adapter.client.list_buckets()
        buckets = [bucket["Name"] for bucket in response["Buckets"]]
        logger.info("Retrieved list of S3 buckets successfully.")
        return {"buckets": buckets}
    except Exception as e:
        logger.error(f"Failed to list S3 buckets: {e}")
        return {"message": "Could not list S3 buckets"}


app.include_router(router, prefix=config.APP_PATH)
