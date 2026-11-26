from uuid import UUID, uuid4

from app.models.chat import ChatSession


class SessionService:
    def __init__(self) -> None:
        self._sessions: dict[UUID, ChatSession] = {}

    def create(self) -> ChatSession:
        session = ChatSession(session_id=uuid4())
        self._sessions[session.session_id] = session
        return session

    def get(self, session_id: UUID) -> ChatSession | None:
        return self._sessions.get(session_id)

    def list(self) -> list[ChatSession]:
        return sorted(
            self._sessions.values(),
            key=lambda session: session.updated_at,
            reverse=True,
        )

    def delete(self, session_id: UUID) -> bool:
        return self._sessions.pop(session_id, None) is not None
