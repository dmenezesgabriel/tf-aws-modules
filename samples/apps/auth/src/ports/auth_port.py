from abc import ABC, abstractmethod
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
    def get_user(self, email: EmailStr) -> Dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def user_signin(self, data: UserSignin) -> SignInResponse:
        raise NotImplementedError

    @abstractmethod
    def forgot_password(self, email: EmailStr) -> Dict[str, Any]:
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
    def new_access_token(self, refresh_token: str) -> Dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def logout(self, access_token: str) -> Dict[str, Any]:
        raise NotImplementedError
