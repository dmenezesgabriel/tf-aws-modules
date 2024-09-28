from abc import ABC, abstractmethod
from typing import Any, Dict

from pydantic import EmailStr

from src.common.dto import (
    AccessTokenResponse,
    ChangePassword,
    ConfirmForgotPassword,
    ForgotPasswordResponse,
    GetUserResponse,
    SignUpResponse,
    UserSignin,
    UserSignup,
    UserVerify,
)


class AuthPort(ABC):
    @abstractmethod
    def user_signup(self, user: UserSignup) -> SignUpResponse:
        raise NotImplementedError

    @abstractmethod
    def verify_account(self, data: UserVerify) -> Dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def resend_confirmation_code(self, email: EmailStr) -> Dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def get_user(self, email: EmailStr) -> GetUserResponse:
        raise NotImplementedError

    @abstractmethod
    def user_signin(self, data: UserSignin) -> AccessTokenResponse:
        raise NotImplementedError

    @abstractmethod
    def forgot_password(self, email: EmailStr) -> ForgotPasswordResponse:
        raise NotImplementedError

    @abstractmethod
    def confirm_forgot_password(
        self, data: ConfirmForgotPassword
    ) -> Dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def change_password(self, data: ChangePassword) -> Dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def new_access_token(self, refresh_token: str) -> AccessTokenResponse:
        raise NotImplementedError

    @abstractmethod
    def logout(self, access_token: str) -> Dict[str, Any]:
        raise NotImplementedError
