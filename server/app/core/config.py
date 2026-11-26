import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parents[2]
load_dotenv(PROJECT_ROOT / ".env")


@dataclass(frozen=True)
class Settings:
    groq_api_key: str | None
    cors_origins: tuple[str, ...]
    data_dir: Path
    vector_db_dir: Path


def get_settings() -> Settings:
    origins = os.getenv(
        "CORS_ORIGINS", "http://localhost:3000,http://localhost:5173"
    )
    return Settings(
        groq_api_key=os.getenv("GROQ_API_KEY"),
        cors_origins=tuple(
            origin.strip() for origin in origins.split(",") if origin.strip()
        ),
        data_dir=PROJECT_ROOT / "data",
        vector_db_dir=PROJECT_ROOT / "vector_db_dir",
    )
