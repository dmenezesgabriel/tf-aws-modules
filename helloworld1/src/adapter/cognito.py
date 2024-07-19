import logging

import boto3  # type: ignore
import botocore
import botocore.exceptions
from pydantic import EmailStr
from src.adapter.dto import (
    ChangePassword,
    ConfirmForgotPassword,
    UserSignin,
    UserSignup,
    UserVerify,
)
from src.config import get_config

logger = logging.getLogger(__name__)
config = get_config()


class AWSCognitoAdapter:
    def __init__(self):
        self.__client = self._create_client()

    def _create_client(self):
        try:
            client = boto3.client(
                "cognito-idp",
                endpoint_url=config.AWS_ENDPOINT_URL,
                aws_access_key_id=config.aws_access_key_id,
                aws_secret_access_key=config.aws_secret_access_key,
                aws_session_token=config.aws_session_token,
                region_name=config.AWS_REGION_NAME,
            )
            logger.info("Cognito client connected successfully.")
            return client
        except Exception as error:
            logger.error(f"Failed to create cognito client: {error}")
            raise

    def user_signup(self, user: UserSignup):
        try:
            response = self.__client.sign_up(
                ClientId=config.AWS_COGNITO_APP_CLIENT_ID,
                Username=user.email,
                Password=user.password,
                UserAttributes=[
                    {
                        "Name": "name",
                        "Value": user.full_name,
                    },
                    {
                        "Name": "email",
                        "Value": user.email,
                    },
                    {"Name": "custom:role", "Value": user.role},
                ],
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def verify_account(self, data: UserVerify):
        try:
            response = self.__client.confirm_sign_up(
                ClientId=config.AWS_COGNITO_APP_CLIENT_ID,
                Username=data.email,
                ConfirmationCode=data.confirmation_code,
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def resend_confirmation_code(self, email: EmailStr):
        try:
            response = self.__client.resend_confirmation_code(
                ClientId=config.AWS_COGNITO_APP_CLIENT_ID, Username=email
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def check_user_exists(self, email: EmailStr):
        try:
            response = self.__client.admin_get_user(
                UserPoolId=config.AWS_COGNITO_USER_POOL_ID, Username=email
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def user_signin(self, data: UserSignin):
        try:
            response = self.__client.initiate_auth(
                ClientId=config.AWS_COGNITO_APP_CLIENT_ID,
                AuthFlow="USER_PASSWORD_AUTH",
                AuthParameters={
                    "USERNAME": data.email,
                    "PASSWORD": data.password,
                },
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def forgot_password(self, email: EmailStr):
        try:
            response = self.__client.forgot_password(
                ClientId=config.AWS_COGNITO_APP_CLIENT_ID, Username=email
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def confirm_forgot_password(self, data: ConfirmForgotPassword):
        try:
            response = self.__client.confirm_forgot_password(
                ClientId=config.AWS_COGNITO_APP_CLIENT_ID,
                Username=data.email,
                ConfirmationCode=data.confirmation_code,
                Password=data.new_password,
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def change_password(self, data: ChangePassword):
        try:
            response = self.__client.change_password(
                PreviousPassword=data.old_password,
                ProposedPassword=data.new_password,
                AccessToken=data.access_token,
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def new_access_token(self, refresh_token: str):
        try:
            response = self.__client.initiate_auth(
                ClientId=config.AWS_COGNITO_APP_CLIENT_ID,
                AuthFlow="REFRESH_TOKEN_AUTH",
                AuthParameters={
                    "REFRESH_TOKEN": refresh_token,
                },
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def logout(self, access_token: str):
        try:
            response = self.__client.global_sign_out(AccessToken=access_token)
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(str(error.response))
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise
