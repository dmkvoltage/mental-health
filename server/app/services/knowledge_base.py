import os
from typing import Any

from app.core.config import Settings
from app.models.chat import SourceReference

MODEL_NAME = "llama-3.3-70b-versatile"

SYSTEM_PROMPT = """You are a specialized mental health assistant focused exclusively on mental health topics.
Provide empathetic, concise, evidence-based information from the supplied context.
If the context does not contain relevant information, say so and explain that you can only discuss mental health topics.
Do not diagnose, prescribe medication, or claim to be a licensed professional.
Encourage professional support when appropriate."""

NEGATIVE_PROMPT = """Do not encourage harmful behavior or provide dangerous advice.
Do not make assumptions about a user's mental state.
Do not provide generic advice unsupported by the context."""


class KnowledgeBase:
    def __init__(self, chain: Any) -> None:
        self._chain = chain

    @classmethod
    def load(cls, settings: Settings) -> "KnowledgeBase":
        from langchain.chains import ConversationalRetrievalChain
        from langchain.prompts import PromptTemplate
        from langchain_chroma import Chroma
        from langchain_groq import ChatGroq
        from langchain_huggingface import HuggingFaceEmbeddings

        database_path = settings.vector_db_dir / "chroma.sqlite3"
        if not database_path.is_file():
            raise RuntimeError(
                "The Chroma vector database was not found. Run "
                "`python -m scripts.build_vector_store` to build it."
            )
        if not settings.groq_api_key:
            raise RuntimeError(
                "GROQ_API_KEY is required. Add it to the environment or the .env file."
            )

        os.environ["GROQ_API_KEY"] = settings.groq_api_key
        embeddings = HuggingFaceEmbeddings()
        vectorstore = Chroma(
            persist_directory=str(settings.vector_db_dir),
            embedding_function=embeddings,
        )
        llm = ChatGroq(model=MODEL_NAME, temperature=0)
        prompt = PromptTemplate(
            template=f"""{SYSTEM_PROMPT}

{NEGATIVE_PROMPT}

Context (from mental health database):
{{context}}

Chat History:
{{chat_history}}

Question: {{question}}

Answer:""",
            input_variables=["context", "chat_history", "question"],
        )
        chain = ConversationalRetrievalChain.from_llm(
            llm=llm,
            retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
            chain_type="stuff",
            return_source_documents=True,
            combine_docs_chain_kwargs={"prompt": prompt},
        )
        return cls(chain)

    def answer(
        self, question: str, chat_history: list[tuple[str, str]]
    ) -> tuple[str, list[SourceReference]]:
        result = self._chain.invoke(
            {"question": question, "chat_history": chat_history}
        )
        return str(result["answer"]), self._extract_sources(result)

    @staticmethod
    def _extract_sources(result: dict[str, Any]) -> list[SourceReference]:
        sources: list[SourceReference] = []
        seen: set[tuple[str, int | None]] = set()
        for document in result.get("source_documents", []):
            source = document.metadata.get("source")
            if not source:
                continue
            page = document.metadata.get("page")
            if not isinstance(page, int):
                page = None
            reference = SourceReference(source=str(source), page=page)
            key = (reference.source, reference.page)
            if key not in seen:
                sources.append(reference)
                seen.add(key)
        return sources
