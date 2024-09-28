from typing import Annotated, List

from annotated_types import MaxLen, MinLen
from pydantic import BaseModel, EmailStr, Field
from typing_extensions import TypedDict


class UserSignup(BaseModel):
    full_name: str = Field(max_length=50)
    email: EmailStr
    password: Annotated[str, MinLen(8)]
    role: str


class UserVerify(BaseModel):
    email: EmailStr
    confirmation_code: Annotated[str, MaxLen(6)]


class UserSignin(BaseModel):
    email: EmailStr
    password: Annotated[str, MinLen(8)]


class ConfirmForgotPassword(BaseModel):
    email: EmailStr
    confirmation_code: Annotated[str, MaxLen(6)]
    new_password: Annotated[str, MinLen(8)]


class ChangePassword(BaseModel):
    old_password: Annotated[str, MinLen(8)]
    new_password: Annotated[str, MinLen(8)]
    access_token: str


class RefreshToken(BaseModel):
    refresh_token: str


class AccessToken(BaseModel):
    access_token: str


class SignUpDict(TypedDict):
    user_id: str
    user_confirmed: bool
    code_delivery_destination: str
    code_delivery_type: str


class SignUpResponse(BaseModel):
    data: List[SignUpDict]
