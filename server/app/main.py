from contextlib import asynccontextmanager
from typing import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import chat, health, sessions
from app.core.config import Settings, get_settings
from app.services.chat_service import ChatService
from app.services.knowledge_base import KnowledgeBase
from app.services.session_service import SessionService


def build_knowledge_base(settings: Settings) -> KnowledgeBase:
    return KnowledgeBase.load(settings)


def create_app() -> FastAPI:
    cors_origins = get_settings().cors_origins

    @asynccontextmanager
    async def lifespan(application: FastAPI) -> AsyncIterator[None]:
        settings = get_settings()
        if not settings.groq_api_key:
            raise RuntimeError(
                "GROQ_API_KEY is required. Add it to the environment or the .env file."
            )
        knowledge_base = build_knowledge_base(settings)
        application.state.session_service = SessionService()
        application.state.chat_service = ChatService(knowledge_base)
        yield

    application = FastAPI(
        title="Mental Health Chatbot API",
        description="Frontend-independent API for the mental health RAG chatbot.",
        version="1.0.0",
        lifespan=lifespan,
    )
    application.add_middleware(
        CORSMiddleware,
        allow_origins=list(cors_origins),
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    application.include_router(health.router)
    application.include_router(chat.router)
    application.include_router(sessions.router)
    return application


app = create_app()
