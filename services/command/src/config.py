import os


class Config:
    APP_PATH = "/command"
    AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
    AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
    AWS_SESSION_TOKEN = os.getenv("AWS_SESSION_TOKEN")
    AWS_ENDPOINT_URL = os.getenv("AWS_ENDPOINT_URL")
    AWS_REGION_NAME = os.getenv("AWS_REGION_NAME")
    AWS_COGNITO_APP_CLIENT_ID = os.getenv("AWS_COGNITO_APP_CLIENT_ID")
    AWS_COGNITO_APP_CLIENT_SECRET = os.getenv("AWS_COGNITO_APP_CLIENT_SECRET")
    AWS_COGNITO_USER_POOL_ID = os.getenv("AWS_COGNITO_USER_POOL_ID")


def get_config():
    return Config()
