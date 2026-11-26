from fastapi import APIRouter, Request

router = APIRouter()


@router.get("/")
async def root(request: Request) -> dict[str, str]:
    return {
        "name": request.app.title,
        "health": "/health",
        "documentation": "/docs",
    }


@router.get("/health")
async def health(request: Request) -> dict[str, str]:
    ready = getattr(request.app.state, "chat_service", None) is not None
    return {"status": "ready" if ready else "not_ready"}
