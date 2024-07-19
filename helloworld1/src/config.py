import os

import boto3  # type: ignore


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

    def __init__(self):
        self._aws_access_key_id = self.AWS_ACCESS_KEY_ID
        self._aws_secret_access_key = self.AWS_SECRET_ACCESS_KEY
        self._aws_session_token = self.AWS_SESSION_TOKEN
        if not self.AWS_ENDPOINT_URL:
            session = boto3.Session()
            credentials = session.get_credentials()
            self._aws_access_key_id = credentials.access_key
            self._aws_secret_access_key = credentials.secret_key
            self._aws_session_token = credentials.token

    @property
    def aws_access_key_id(self):
        return self._aws_access_key_id

    @property
    def aws_secret_access_key(self):
        return self._aws_secret_access_key

    @property
    def aws_session_token(self):
        return self._aws_session_token


def get_config():
    return Config()
