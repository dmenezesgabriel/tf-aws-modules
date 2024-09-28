import logging

from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from pydantic import EmailStr
from starlette.responses import Response

from src.adapters.exceptions import (
    LimitExceededException,
    TooManyRequestsException,
)
from src.common.dto import (
    AccessToken,
    ChangePassword,
    ConfirmForgotPassword,
    RefreshToken,
    SignUpResponse,
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
            "/signup",
            self.signup_user,
            methods=["POST"],
            tags=["Sign up"],
            response_model=SignUpResponse,
            status_code=200,
        )
        self.router.add_api_route(
            "/verify_account",
            self.verify_account,
            methods=["POST"],
            tags=["Account confirmation"],
            status_code=204,
        )
        self.router.add_api_route(
            "/resend_confirmation_code",
            self.resend_confirmation_code,
            methods=["POST"],
            tags=["Account confirmation"],
        )
        self.router.add_api_route(
            "/signin", self.signin, methods=["POST"], tags=["Sign in"]
        )
        self.router.add_api_route(
            "/forgot_password",
            self.forgot_password,
            methods=["POST"],
            tags=["Password"],
        )
        self.router.add_api_route(
            "/confirm_forgot_password",
            self.confirm_forgot_password,
            methods=["POST"],
            tags=["Password"],
        )
        self.router.add_api_route(
            "/change_password",
            self.change_password,
            methods=["POST"],
            tags=["Password"],
        )
        self.router.add_api_route(
            "/new_access_token",
            self.new_access_token,
            methods=["POST"],
            tags=["Refresh token"],
        )
        self.router.add_api_route(
            "/logout", self.logout, methods=["POST"], tags=["Logout"]
        )
        self.router.add_api_route(
            "/user_details",
            self.user_details,
            methods=["POST"],
            tags=["User details"],
        )

    def signup_user(self, user: UserSignup) -> SignUpResponse:
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

    def verify_account(self, data: UserVerify) -> Response:
        try:
            self.__auth_service.verify_account(data)
            return Response(status_code=204)
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

    def resend_confirmation_code(self, email: EmailStr) -> JSONResponse:
        try:
            content = self.__auth_service.resend_confirmation_code(email)
            return JSONResponse(status_code=200, content=content)
        except UserNotFoundException:
            raise HTTPException(status_code="404", detail="User not found.")
        except LimitExceededException:
            raise HTTPException(status_code=429, detail="Limit Exceeded.")
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def signin(self, data: UserSignin) -> JSONResponse:
        try:
            content = self.__auth_service.user_signin(data)
            return JSONResponse(status_code=200, content=content)
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
    ) -> JSONResponse:
        try:
            content = self.__auth_service.forgot_password(email)
            return JSONResponse(status_code=200, content=content)
        except UserNotFoundException:
            raise HTTPException(status_code="404", detail="User not found.")
        except Exception:
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )

    def confirm_forgot_password(
        self, data: ConfirmForgotPassword
    ) -> JSONResponse:
        try:
            content = self.__auth_service.confirm_forgot_password(data)
            return JSONResponse(status_code=200, content=content)
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

    def change_password(self, data: ChangePassword) -> JSONResponse:
        try:
            content = self.__auth_service.change_password(data)
            return JSONResponse(status_code=200, content=content)
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

    def new_access_token(self, refresh_token: RefreshToken) -> JSONResponse:
        try:
            content = self.__auth_service.new_access_token(
                refresh_token.refresh_token
            )
            return JSONResponse(status_code=200, content=content)
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

    def logout(self, access_token: AccessToken) -> JSONResponse:
        try:
            content = self.__auth_service.logout(access_token.access_token)
            return JSONResponse(status_code=200, content=content)
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

    def user_details(self, email: EmailStr) -> JSONResponse:
        try:
            content = self.__auth_service.user_details(email)
            return JSONResponse(status_code=200, content=content)
        except Exception as error:
            logger.info(error)
            raise HTTPException(
                status_code=500,
                detail="Internal Server Error.",
            )
