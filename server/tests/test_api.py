import pytest
from fastapi.testclient import TestClient

from app import main as app_module
from app.core.safety import contains_sensitive_topics
from app.models.chat import SourceReference


class StubKnowledgeBase:
    def __init__(self) -> None:
        self.calls: list[tuple[str, list[tuple[str, str]]]] = []

    def answer(
        self, question: str, chat_history: list[tuple[str, str]]
    ) -> tuple[str, list[SourceReference]]:
        self.calls.append((question, chat_history))
        return "Here is a context-based response.", [
            SourceReference(source="guide.pdf", page=2)
        ]


@pytest.fixture
def api_client(monkeypatch: pytest.MonkeyPatch):
    knowledge_base = StubKnowledgeBase()
    monkeypatch.setenv("GROQ_API_KEY", "test-key")
    monkeypatch.setattr(
        app_module,
        "build_knowledge_base",
        lambda _: knowledge_base,
    )

    with TestClient(app_module.app) as client:
        yield client, knowledge_base


def test_chat_creates_and_reuses_session_with_sources(api_client) -> None:
    client, knowledge_base = api_client

    assert client.get("/health").json() == {"status": "ready"}
    assert client.get("/").status_code == 200

    first = client.post("/api/chat", json={"message": "What is stress?"})
    assert first.status_code == 200
    first_data = first.json()
    session_id = first_data["session_id"]
    assert first_data["sources"] == [{"source": "guide.pdf", "page": 2}]

    second = client.post(
        "/api/chat",
        json={"session_id": session_id, "message": "Can you explain more?"},
    )
    assert second.status_code == 200
    assert knowledge_base.calls[1][1] == [
        ("What is stress?", "Here is a context-based response.")
    ]

    history = client.get(f"/api/sessions/{session_id}")
    assert history.status_code == 200
    assert history.json()["message_count"] == 4
    assert len(client.get("/api/sessions").json()) == 1


def test_crisis_message_bypasses_model_and_session_can_be_deleted(api_client) -> None:
    client, knowledge_base = api_client
    session_id = client.post("/api/sessions").json()["session_id"]

    result = client.post(
        "/api/chat",
        json={"session_id": session_id, "message": "I want to kill myself"},
    )
    assert result.status_code == 200
    assert result.json()["safety_notice"] is True
    assert "local emergency services" in result.json()["response"]
    assert knowledge_base.calls == []

    exported = client.get(f"/api/sessions/{session_id}/export")
    assert exported.status_code == 200
    assert exported.content.startswith(b"%PDF")

    deleted = client.delete(f"/api/sessions/{session_id}")
    assert deleted.status_code == 204
    assert client.get(f"/api/sessions/{session_id}").status_code == 404


def test_chat_rejects_blank_messages_and_unknown_sessions(api_client) -> None:
    client, _ = api_client

    assert contains_sensitive_topics("I enjoy learning new skills") is False
    assert client.post("/api/chat", json={"message": "   "}).status_code == 422
    assert (
        client.post(
            "/api/chat",
            json={
                "session_id": "00000000-0000-0000-0000-000000000001",
                "message": "Hello",
            },
        ).status_code
        == 404
    )
