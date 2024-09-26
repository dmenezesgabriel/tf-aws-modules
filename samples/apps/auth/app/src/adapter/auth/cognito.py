import logging

import botocore
import botocore.exceptions
from pydantic import EmailStr
from src.adapter.cloud.aws.client import AWSClientAdapter
from src.common.dto import (
    ChangePassword,
    ConfirmForgotPassword,
    UserSignin,
    UserSignup,
    UserVerify,
)
from src.config import get_config

logger = logging.getLogger()
config = get_config()


class AWSCognitoAdapter(AWSClientAdapter):
    def __init__(self, client_type="cognito-idp"):
        super().__init__(client_type=client_type)
        self.cognito_app_pool_id = config.get_parameter(
            "AWS_COGNITO_USER_POOL_ID"
        )
        self.cognito_user_pool_client_id = config.get_parameter(
            "AWS_COGNITO_APP_CLIENT_ID"
        )

    def user_signup(self, user: UserSignup):
        try:
            response = self.client.sign_up(
                ClientId=self.cognito_user_pool_client_id,
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
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def verify_account(self, data: UserVerify):
        try:
            response = self.client.confirm_sign_up(
                ClientId=self.cognito_user_pool_client_id,
                Username=data.email,
                ConfirmationCode=data.confirmation_code,
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def resend_confirmation_code(self, email: EmailStr):
        try:
            response = self.client.resend_confirmation_code(
                ClientId=self.cognito_user_pool_client_id, Username=email
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def check_user_exists(self, email: EmailStr):
        try:
            response = self.client.admin_get_user(
                UserPoolId=self.cognito_app_pool_id, Username=email
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def user_signin(self, data: UserSignin):
        try:
            response = self.client.initiate_auth(
                ClientId=self.cognito_user_pool_client_id,
                AuthFlow="USER_PASSWORD_AUTH",
                AuthParameters={
                    "USERNAME": data.email,
                    "PASSWORD": data.password,
                },
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def forgot_password(self, email: EmailStr):
        try:
            response = self.client.forgot_password(
                ClientId=self.cognito_user_pool_client_id, Username=email
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def confirm_forgot_password(self, data: ConfirmForgotPassword):
        try:
            response = self.client.confirm_forgot_password(
                ClientId=self.cognito_user_pool_client_id,
                Username=data.email,
                ConfirmationCode=data.confirmation_code,
                Password=data.new_password,
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def change_password(self, data: ChangePassword):
        try:
            response = self.client.change_password(
                PreviousPassword=data.old_password,
                ProposedPassword=data.new_password,
                AccessToken=data.access_token,
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def new_access_token(self, refresh_token: str):
        try:
            response = self.client.initiate_auth(
                ClientId=self.cognito_user_pool_client_id,
                AuthFlow="REFRESH_TOKEN_AUTH",
                AuthParameters={
                    "REFRESH_TOKEN": refresh_token,
                },
            )
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise

    def logout(self, access_token: str):
        try:
            response = self.client.global_sign_out(AccessToken=access_token)
            return response
        except botocore.exceptions.ClientError as error:
            logger.error(error.response)
            return error.response
        except Exception as error:
            logger.error(f"SignUp error: {error}")
            raise
