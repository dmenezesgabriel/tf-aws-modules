import logging
from enum import Enum
from typing import Literal, Optional

import jwt
from fastapi import HTTPException, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from starlette.status import HTTP_401_UNAUTHORIZED, HTTP_403_FORBIDDEN

from src.adapters.cloud.aws.client import AWSClientAdapter
from src.config import get_config

config = get_config()
logger = logging.getLogger(__name__)


class CognitoTokenUse(Enum):
    ID = "id"
    ACCESS = "access"


class CognitoJWTAuthorizer(HTTPBearer):

    def __init__(
        self,
        required_token_use: CognitoTokenUse,
        aws_default_region: str,
        cognito_user_pool_id: str,
        cognito_user_pool_client_id: str,
        jwks_client: jwt.PyJWKClient,
        auto_error: bool = True,
    ) -> None:
        super().__init__(auto_error=auto_error)
        self.required_token_use = required_token_use
        self.aws_default_region = aws_default_region
        self.cognito_user_pool_id = cognito_user_pool_id
        self.cognito_user_pool_client_id = cognito_user_pool_client_id
        self.jwks_client = jwks_client

    async def __call__(self, request: Request):
        credentials: Optional[HTTPAuthorizationCredentials] = (
            await super().__call__(request)
        )

        if not credentials:
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
            )
        if not credentials.scheme == "Bearer":
            raise HTTPException(
                status_code=HTTP_403_FORBIDDEN,
                detail="Wrong authentication method",
            )
        token: str = credentials.credentials

        try:
            signing_key: jwt.PyJWK = self.jwks_client.get_signing_key_from_jwt(
                token
            )
        except jwt.exceptions.InvalidTokenError as e:
            logger.error(3)
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
            ) from e

        try:
            claims = jwt.decode(
                token,
                signing_key.key,
                algorithms=["RS256"],
                issuer=config.get_parameter("AWS_COGNITO_ISSUER_URI"),
                options={
                    "verify_aud": False,
                    "verify_signature": True,
                    "verify_exp": True,
                    "verify_iss": True,
                    "require": ["token_use", "exp", "iss", "sub"],
                },
            )
        except jwt.exceptions.ExpiredSignatureError as e:
            logger.error(4)
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
            ) from e
        except jwt.exceptions.InvalidTokenError as e:
            logger.error(4)
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
            ) from e
        if self.required_token_use.value != claims["token_use"]:
            logger.error(5)
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
            )
        if self.required_token_use == CognitoTokenUse.ID:
            if "aud" not in claims:
                logger.error(6)
                raise HTTPException(
                    status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
                )
            if claims["aud"] != self.cognito_user_pool_client_id:
                logger.error(6)
                raise HTTPException(
                    status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
                )
        elif self.required_token_use == CognitoTokenUse.ACCESS:
            if "client_id" not in claims:
                logger.error(7)
                raise HTTPException(
                    status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
                )
            if claims["client_id"] != self.cognito_user_pool_client_id:
                logger.error(8)
                raise HTTPException(
                    status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
                )
        else:
            logger.error(9)
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED, detail="Unauthorized"
            )


class CognitoAuthorizerFactory:
    def __init__(self):
        self.__jwks_client = jwt.PyJWKClient(
            config.get_parameter("AWS_COGNITO_JWK_URI")
        )
        self.__aws_client = AWSClientAdapter(client_type="sts")

    def __create_access_token_authorizer(self):
        return CognitoJWTAuthorizer(
            CognitoTokenUse.ACCESS,
            self.__aws_client.aws_region_name,
            config.get_parameter("AWS_COGNITO_USER_POOL_ID"),
            config.get_parameter("AWS_COGNITO_APP_CLIENT_ID"),
            self.__jwks_client,
        )

    def __create_access_id_authorizer(self):
        return CognitoJWTAuthorizer(
            CognitoTokenUse.ID,
            self.__aws_client.aws_region_name,
            config.get_parameter("AWS_COGNITO_USER_POOL_ID"),
            config.get_parameter("AWS_COGNITO_APP_CLIENT_ID"),
            self.__jwks_client,
        )

    def get(self, type: Literal["access_token", "access_id"]):
        authorizers = {
            "access_token": self.__create_access_token_authorizer,
            "access_id": self.__create_access_id_authorizer,
        }
        return authorizers[type]()
