import logging

from fastapi import APIRouter
from pydantic import EmailStr
from src.adapter.dto import (
    AccessToken,
    ChangePassword,
    ConfirmForgotPassword,
    RefreshToken,
    UserSignin,
    UserSignup,
    UserVerify,
)

logger = logging.getLogger()


class HTTPApiAdapter:
    def __init__(self, auth_service):
        self.__auth_service = auth_service
        self.router = APIRouter()
        self.router.add_api_route(
            "/signup", self.signup_user, methods=["POST"]
        )
        self.router.add_api_route(
            "/verify_account",
            self.verify_account,
            methods=["POST"],
        )
        self.router.add_api_route(
            "/resend_confirmation_code",
            self.resend_confirmation_code,
            methods=["POST"],
        )
        self.router.add_api_route("/signin", self.signin, methods=["POST"])
        self.router.add_api_route(
            "/forgot_password", self.forgot_password, methods=["POST"]
        )
        self.router.add_api_route(
            "/confirm_forgot_password",
            self.confirm_forgot_password,
            methods=["POST"],
        )
        self.router.add_api_route(
            "/change_password", self.change_password, methods=["POST"]
        )
        self.router.add_api_route(
            "/new_access_token", self.new_access_token, methods=["POST"]
        )
        self.router.add_api_route("/logout", self.logout, methods=["POST"])
        self.router.add_api_route(
            "/user_details", self.user_details, methods=["POST"]
        )

    def signup_user(self, user: UserSignup):
        return self.__auth_service.user_signup(user)

    def verify_account(self, data: UserVerify):
        return self.__auth_service.verify_account(data)

    def resend_confirmation_code(self, email: EmailStr):
        return self.__auth_service.resend_confirmation_code(email)

    def signin(self, data: UserSignin):
        return self.__auth_service.user_signin(data)

    def forgot_password(
        self,
        email: EmailStr,
    ):
        return self.__auth_service.forgot_password(email)

    def confirm_forgot_password(self, data: ConfirmForgotPassword):
        return self.__auth_service.confirm_forgot_password(data)

    def change_password(self, data: ChangePassword):
        return self.__auth_service.change_password(data)

    def new_access_token(self, refresh_token: RefreshToken):
        return self.__auth_service.new_access_token(
            refresh_token.refresh_token
        )

    def logout(self, access_token: AccessToken):
        return self.__auth_service.logout(access_token.access_token)

    def user_details(self, email: EmailStr):
        return self.__auth_service.user_details(email)
