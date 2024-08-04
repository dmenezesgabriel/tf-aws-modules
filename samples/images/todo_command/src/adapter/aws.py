import logging
import os

import boto3  # type: ignore

logger = logging.getLogger()


class AWSClientAdapter:
    def __init__(self, client_type):
        self._type = client_type
        self._aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
        self._aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
        self._aws_session_token = os.getenv("AWS_SESSION_TOKEN")
        self._aws_endpoint_url = os.getenv("AWS_ENDPOINT_URL")
        self._aws_region_name = os.getenv("AWS_REGION_NAME")

        if not self.aws_endpoint_url:
            self.__set_credentials()

        self._client = self.__create_client()

    def __set_credentials(self):
        try:
            session = boto3.Session()
            credentials = session.get_credentials()
            self._aws_access_key_id = credentials.access_key
            self._aws_secret_access_key = credentials.secret_key
            self._aws_session_token = credentials.token
            logger.info("Got credentials from boto session")
        except Exception as error:
            logger.error(f"Failed to get credentials from session: {error}")
            raise

    def __create_client(self):
        try:
            client = boto3.client(
                self._type,
                endpoint_url=self.aws_endpoint_url,
                aws_access_key_id=self.aws_access_key_id,
                aws_secret_access_key=self.aws_secret_access_key,
                aws_session_token=self.aws_session_token,
                region_name=self.aws_region_name,
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

    @property
    def aws_endpoint_url(self):
        return self._aws_endpoint_url

    @property
    def aws_region_name(self):
        return self._aws_region_name
