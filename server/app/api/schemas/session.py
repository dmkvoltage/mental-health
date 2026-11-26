from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel


class MessageResponse(BaseModel):
    role: Literal["user", "assistant"]
    content: str
    created_at: datetime


class SessionSummary(BaseModel):
    session_id: UUID
    created_at: datetime
    updated_at: datetime
    message_count: int


class SessionDetail(SessionSummary):
    messages: list[MessageResponse]
