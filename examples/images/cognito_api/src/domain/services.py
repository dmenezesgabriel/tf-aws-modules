import logging

from pydantic import EmailStr
from src.adapter.dto import (
    ChangePassword,
    ConfirmForgotPassword,
    UserSignin,
    UserSignup,
    UserVerify,
)

logger = logging.getLogger()


class AuthService:
    def __init__(self, auth_adapter):
        self.__auth_adapter = auth_adapter

    def user_signup(self, user: UserSignup):
        try:
            response = self.__auth_adapter.user_signup(user)
            return response
        except Exception as error:
            logger.error(error)

    def verify_account(self, data: UserVerify):
        try:
            response = self.__auth_adapter.verify_account(data)
            return response
        except Exception as error:
            logger.error(error)

    def resend_confirmation_code(self, email: EmailStr):
        try:
            response = self.__auth_adapter.check_user_exists(email)
            return response
        except Exception as error:
            logger.error(error)
        try:
            response = self.__auth_adapter.resend_confirmation_code(email)
            return response
        except Exception as error:
            logger.error(error)

    def user_signin(self, data: UserSignin):
        try:
            response = self.__auth_adapter.user_signin(data)
            return response
        except Exception as error:
            logger.error(error)

    def forgot_password(self, email: EmailStr):
        try:
            response = self.__auth_adapter.forgot_password(email)
            return response
        except Exception as error:
            logger.error(error)

    def confirm_forgot_password(self, data: ConfirmForgotPassword):
        try:
            response = self.__auth_adapter.confirm_forgot_password(data)
            return response
        except Exception as error:
            logger.error(error)

    def change_password(self, data: ChangePassword):
        try:
            response = self.__auth_adapter.change_password(data)
            return response
        except Exception as error:
            logger.error(error)

    def new_access_token(self, refresh_token: str):
        try:
            response = self.__auth_adapter.new_access_token(refresh_token)
            return response
        except Exception as error:
            logger.error(error)

    def logout(self, access_token: str):
        try:
            response = self.__auth_adapter.logout(access_token)
            return response
        except Exception as error:
            logger.error(error)

    def user_details(self, email: EmailStr):
        try:
            response = self.__auth_adapter.check_user_exists(email)
            return response
        except Exception as error:
            logger.error(error)
