from typing import Optional
from uuid import UUID

from pydantic import BaseModel


class TodoCreateRequestDTO(BaseModel):
    title: str
    description: str
    done: bool


class TodoUpdateRequestDTO(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    done: Optional[bool] = None


class TodoResponseDTO(BaseModel):
    title: str
    description: str
    done: bool
    id: Optional[UUID] = None
