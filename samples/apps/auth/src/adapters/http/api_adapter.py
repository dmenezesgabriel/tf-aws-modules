import logging
from typing import Any, Dict

from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from pydantic import EmailStr

from src.adapters.exceptions import (
    LimitExceededException,
    ParameterNotFoundException,
    ParameterStoreException,
    TooManyRequestsException,
)
from src.common.dto import (
    AccessToken,
    ChangePassword,
    ConfirmForgotPassword,
    RefreshToken,
    UserSignin,
    UserSignup,
    UserVerify,
)
from src.domain.exceptions import (
    ExpiredVerificationCodeException,
    InvalidCredentialsException,
    InvalidVerificationCodeException,
    RequirementsDoesNotMatchException,
    UnauthorizedException,
    UserAlreadyExistsException,
    UserNotConfirmedException,
    UserNotFoundException,
)
from src.domain.services.auth_service import AuthService

logger = logging.getLogger()


class HTTPApiAdapter:
    def __init__(self, auth_service: AuthService) -> None:
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

    def signup_user(self, user: UserSignup) -> Dict[str, Any]:
        try:
            return self.__auth_service.user_signup(user)
        except UserAlreadyExistsException:
            raise HTTPException(
                status_code=409,
                detail="An account with the given email already exists.",
            )
        except RequirementsDoesNotMatchException:
            raise HTTPException(
                status_code=400,
                detail="Password requirements does not match.",
            )
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def verify_account(self, data: UserVerify) -> Dict[str, Any]:
        try:
            return self.__auth_service.verify_account(data)
        except InvalidVerificationCodeException:
            raise HTTPException(
                status_code=400,
                detail="he provided code does not match the expected value.",
            )
        except ExpiredVerificationCodeException:
            raise HTTPException(
                status_code=400, detail="The provided code has expired."
            )
        except UserNotFoundException:
            raise HTTPException(status_code=404, detail="User not found.")
        except UnauthorizedException:
            raise HTTPException(status_code=403, detail="Not Authorized.")
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def resend_confirmation_code(self, email: EmailStr) -> Dict[str, Any]:
        try:
            return self.__auth_service.resend_confirmation_code(email)
        except UserNotFoundException:
            raise HTTPException(status_code="404", detail="User not found.")
        except LimitExceededException:
            raise HTTPException(status_code=429, detail="Limit Exceeded.")
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def signin(self, data: UserSignin) -> Dict[str, Any]:
        try:
            return self.__auth_service.user_signin(data)
        except UserNotFoundException:
            raise HTTPException(status_code="404", detail="User not found.")
        except UserNotConfirmedException:
            raise HTTPException(
                status_code="403",
                detail="Please verify if your account is confirmed.",
            )
        except InvalidCredentialsException:
            raise HTTPException(
                status_code=401, detail="Incorrect username or password."
            )
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def forgot_password(
        self,
        email: EmailStr,
    ) -> Dict[str, Any]:
        try:
            return self.__auth_service.forgot_password(email)
        except UserNotFoundException:
            raise HTTPException(status_code="404", detail="User not found.")
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def confirm_forgot_password(
        self, data: ConfirmForgotPassword
    ) -> Dict[str, Any]:
        try:
            return self.__auth_service.confirm_forgot_password(data)
        except ExpiredVerificationCodeException:
            raise HTTPException(status_code="403", detail="Code expired.")
        except InvalidVerificationCodeException:
            raise HTTPException(
                status_code="400", detail="Code does not match."
            )

        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def change_password(self, data: ChangePassword) -> Dict[str, Any]:
        try:
            return self.__auth_service.change_password(data)
        except InvalidCredentialsException:
            raise HTTPException(
                status_code="401", detail="Incorrect username or password."
            )
        except LimitExceededException:
            raise HTTPException(
                status_code="429",
                detail="Attempt limit exceeded, please try again later.",
            )
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def new_access_token(self, refresh_token: RefreshToken) -> Dict[str, Any]:
        try:
            return self.__auth_service.new_access_token(
                refresh_token.refresh_token
            )
        except LimitExceededException:
            raise HTTPException(
                status_code="429",
                detail="Attempt limit exceeded, please try again later.",
            )
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def logout(self, access_token: AccessToken) -> Dict[str, Any]:
        try:
            return self.__auth_service.logout(access_token.access_token)
        except InvalidCredentialsException:
            raise HTTPException(
                status_code="401", detail="Incorrect username or password."
            )
        except TooManyRequestsException:
            raise HTTPException(
                status_code="429",
                detail="Attempt limit exceeded, please try again later.",
            )
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def user_details(self, email: EmailStr) -> Dict[str, Any]:
        try:
            return self.__auth_service.user_details(email)
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )
