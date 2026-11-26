import asyncio
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Response

from app.api.dependencies import get_session_service
from app.api.schemas.session import MessageResponse, SessionDetail, SessionSummary
from app.models.chat import ChatSession
from app.services.pdf_export_service import create_chat_pdf
from app.services.session_service import SessionService

router = APIRouter(prefix="/api/sessions", tags=["sessions"])


def _session_summary(session: ChatSession) -> SessionSummary:
    return SessionSummary(
        session_id=session.session_id,
        created_at=session.created_at,
        updated_at=session.updated_at,
        message_count=len(session.messages),
    )


def _session_detail(session: ChatSession) -> SessionDetail:
    return SessionDetail(
        **_session_summary(session).model_dump(),
        messages=[
            MessageResponse(
                role=message.role,
                content=message.content,
                created_at=message.created_at,
            )
            for message in session.messages
        ],
    )


def _get_or_404(session_service: SessionService, session_id: UUID) -> ChatSession:
    session = session_service.get(session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Chat session not found.")
    return session


@router.post("", response_model=SessionDetail, status_code=201)
async def create_session(
    session_service: SessionService = Depends(get_session_service),
) -> SessionDetail:
    return _session_detail(session_service.create())


@router.get("", response_model=list[SessionSummary])
async def list_sessions(
    session_service: SessionService = Depends(get_session_service),
) -> list[SessionSummary]:
    return [_session_summary(session) for session in session_service.list()]


@router.get("/{session_id}", response_model=SessionDetail)
async def read_session(
    session_id: UUID,
    session_service: SessionService = Depends(get_session_service),
) -> SessionDetail:
    session = _get_or_404(session_service, session_id)
    async with session.lock:
        return _session_detail(session)


@router.delete("/{session_id}", status_code=204)
async def delete_session(
    session_id: UUID,
    session_service: SessionService = Depends(get_session_service),
) -> Response:
    session = _get_or_404(session_service, session_id)
    async with session.lock:
        if not session_service.delete(session_id):
            raise HTTPException(status_code=404, detail="Chat session not found.")
    return Response(status_code=204)


@router.get("/{session_id}/export")
async def export_session(
    session_id: UUID,
    session_service: SessionService = Depends(get_session_service),
) -> Response:
    session = _get_or_404(session_service, session_id)
    async with session.lock:
        pdf_content = await asyncio.to_thread(create_chat_pdf, session)

    return Response(
        content=pdf_content,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f'attachment; filename="mental-health-chat-{session_id}.pdf"'
        },
    )
