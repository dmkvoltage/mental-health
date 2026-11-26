from fastapi import APIRouter, Depends, HTTPException

from app.api.dependencies import get_chat_service, get_session_service
from app.api.schemas.chat import ChatRequest, ChatResponse, SourceDocument
from app.services.chat_service import ChatService
from app.services.session_service import SessionService

router = APIRouter(prefix="/api/chat", tags=["chat"])


@router.post("", response_model=ChatResponse)
async def send_message(
    payload: ChatRequest,
    chat_service: ChatService = Depends(get_chat_service),
    session_service: SessionService = Depends(get_session_service),
) -> ChatResponse:
    if payload.session_id is None:
        session = session_service.create()
    else:
        session = session_service.get(payload.session_id)
        if session is None:
            raise HTTPException(status_code=404, detail="Chat session not found.")

    result = await chat_service.reply(session, payload.message)
    return ChatResponse(
        session_id=session.session_id,
        response=result.response,
        sources=[
            SourceDocument(source=source.source, page=source.page)
            for source in result.sources
        ],
        safety_notice=result.safety_notice,
    )
