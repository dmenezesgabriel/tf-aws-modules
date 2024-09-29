from typing import Annotated, List, Optional

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


class ChangePasswordRequest(BaseModel):
    old_password: Annotated[str, MinLen(8)]
    new_password: Annotated[str, MinLen(8)]


class RefreshToken(BaseModel):
    refresh_token: str


class SignUpDict(TypedDict):
    user_id: str
    user_confirmed: bool
    code_delivery_destination: str
    code_delivery_type: str


class SignUpResponse(BaseModel):
    data: List[SignUpDict]


class AccessTokenDict(TypedDict):
    access_token: str
    expires_in: int
    token_type: str
    id_token: str
    refresh_token: Optional[str]


class AccessTokenResponse(BaseModel):
    data: List[AccessTokenDict]


class ForgotPasswordDict(TypedDict):
    code_delivery_destination: str
    code_delivery_type: str


class ForgotPasswordResponse(BaseModel):
    data: List[ForgotPasswordDict]


class UserAttribute(TypedDict):
    name: str
    value: str


class User(BaseModel):
    username: str
    user_attributes: List[UserAttribute]
    user_created_at: str
    user_last_modified_at: str
    user_status: str
    user_enabled: bool


class GetUserResponse(BaseModel):
    data: List[User]
