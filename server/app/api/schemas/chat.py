from uuid import UUID

from pydantic import BaseModel, Field, field_validator

MAX_MESSAGE_LENGTH = 4000


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=MAX_MESSAGE_LENGTH)
    session_id: UUID | None = None

    @field_validator("message")
    @classmethod
    def message_must_not_be_blank(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Message cannot be blank.")
        return value.strip()


class SourceDocument(BaseModel):
    source: str
    page: int | None = None


class ChatResponse(BaseModel):
    session_id: UUID
    response: str
    sources: list[SourceDocument]
    safety_notice: bool
