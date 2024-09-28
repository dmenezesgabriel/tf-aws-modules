import logging
from typing import Any, Dict

from pydantic import EmailStr

from src.common.dto import (
    ChangePassword,
    ConfirmForgotPassword,
    SignInResponse,
    SignUpResponse,
    UserSignin,
    UserSignup,
    UserVerify,
)
from src.ports.auth_port import AuthPort

logger = logging.getLogger()


class AuthService:
    def __init__(self, auth_adapter: AuthPort) -> None:
        self.__auth_adapter = auth_adapter

    def user_signup(self, user: UserSignup) -> SignUpResponse:
        response = self.__auth_adapter.user_signup(user)
        return response

    def verify_account(self, data: UserVerify) -> Dict[str, Any]:
        response = self.__auth_adapter.verify_account(data)
        return response

    def resend_confirmation_code(self, email: EmailStr) -> Dict[str, Any]:
        response = self.__auth_adapter.resend_confirmation_code(email)
        return response

    def user_signin(self, data: UserSignin) -> SignInResponse:
        response = self.__auth_adapter.user_signin(data)
        return response

    def forgot_password(self, email: EmailStr) -> Dict[str, Any]:
        response = self.__auth_adapter.forgot_password(email)
        return response

    def confirm_forgot_password(
        self, data: ConfirmForgotPassword
    ) -> Dict[str, Any]:
        response = self.__auth_adapter.confirm_forgot_password(data)
        return response

    def change_password(self, data: ChangePassword) -> Dict[str, Any]:
        response = self.__auth_adapter.change_password(data)
        return response

    def new_access_token(self, refresh_token: str) -> Dict[str, Any]:
        response = self.__auth_adapter.new_access_token(refresh_token)
        return response

    def logout(self, access_token: str) -> Dict[str, Any]:
        response = self.__auth_adapter.logout(access_token)
        return response

    def user_details(self, email: EmailStr) -> Dict[str, Any]:
        response = self.__auth_adapter.get_user(email)
        return response
