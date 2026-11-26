import asyncio
from dataclasses import dataclass

from app.core.safety import CRISIS_RESPONSE, contains_sensitive_topics
from app.models.chat import ChatMessage, ChatSession, SourceReference
from app.services.knowledge_base import KnowledgeBase


@dataclass(frozen=True, slots=True)
class ChatResult:
    response: str
    sources: list[SourceReference]
    safety_notice: bool


class ChatService:
    def __init__(self, knowledge_base: KnowledgeBase) -> None:
        self._knowledge_base = knowledge_base

    async def reply(self, session: ChatSession, message: str) -> ChatResult:
        safety_notice = contains_sensitive_topics(message)

        async with session.lock:
            session.messages.append(ChatMessage(role="user", content=message))

            if safety_notice:
                answer = CRISIS_RESPONSE
                sources: list[SourceReference] = []
            else:
                answer, sources = await asyncio.to_thread(
                    self._knowledge_base.answer,
                    message,
                    list(session.history),
                )

            session.history.append((message, answer))
            session.messages.append(ChatMessage(role="assistant", content=answer))
            session.updated_at = session.messages[-1].created_at

        return ChatResult(
            response=answer,
            sources=sources,
            safety_notice=safety_notice,
        )

