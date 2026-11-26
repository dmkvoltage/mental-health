from fastapi import HTTPException, Request

from app.services.chat_service import ChatService
from app.services.session_service import SessionService


def get_chat_service(request: Request) -> ChatService:
    service = getattr(request.app.state, "chat_service", None)
    if service is None:
        raise HTTPException(status_code=503, detail="Chat service is not ready.")
    return service


def get_session_service(request: Request) -> SessionService:
    service = getattr(request.app.state, "session_service", None)
    if service is None:
        raise HTTPException(status_code=503, detail="Chat service is not ready.")
    return service
