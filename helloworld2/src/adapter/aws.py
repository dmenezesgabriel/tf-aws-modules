import logging

import boto3  # type: ignore
from src.config import get_config

config = get_config()
logger = logging.getLogger(__name__)


class AWSClientAdapter:
    def __init__(self, client_type):
        self._type = client_type
        self._aws_access_key_id = config.AWS_ACCESS_KEY_ID
        self._aws_secret_access_key = config.AWS_SECRET_ACCESS_KEY
        self._aws_session_token = config.AWS_SESSION_TOKEN
        if not config.AWS_ENDPOINT_URL:
            session = boto3.Session()
            credentials = session.get_credentials()
            self._aws_access_key_id = credentials.access_key
            self._aws_secret_access_key = credentials.secret_key
            self._aws_session_token = credentials.token

        self._client = self.__create_client()

    def __create_client(self):
        try:
            client = boto3.client(
                self._type,
                endpoint_url=config.AWS_ENDPOINT_URL,
                aws_access_key_id=self.aws_access_key_id,
                aws_secret_access_key=self.aws_secret_access_key,
                aws_session_token=self.aws_session_token,
                region_name=config.AWS_REGION_NAME,
            )
            logger.info(f"{self._type} client connected successfully.")
            return client
        except Exception as error:
            logger.error(f"Failed to create {self._type}: {error}")
            raise

    @property
    def client(self):
        return self._client

    @property
    def aws_access_key_id(self):
        return self._aws_access_key_id

    @property
    def aws_secret_access_key(self):
        return self._aws_secret_access_key

    @property
    def aws_session_token(self):
        return self._aws_session_token
