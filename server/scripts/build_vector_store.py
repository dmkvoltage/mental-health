from pathlib import Path

from PyPDF2 import PdfReader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_chroma import Chroma
from langchain.schema import Document

from app.core.config import get_settings


def load_pdf_documents(directory: Path) -> list[Document]:
    """Extract text from PDF files and retain each source filename."""
    documents: list[Document] = []
    for pdf_path in sorted(directory.glob("*.pdf")):
        try:
            print(f"Processing {pdf_path.name}...")
            reader = PdfReader(str(pdf_path))
            text = "\n".join(page.extract_text() or "" for page in reader.pages)
            documents.append(
                Document(page_content=text, metadata={"source": pdf_path.name})
            )
            print(f"Successfully processed {pdf_path.name}")
        except Exception as error:
            print(f"Error processing {pdf_path.name}: {error}")
    return documents


def build_vector_store(data_dir: Path, vector_db_dir: Path) -> None:
    data_dir.mkdir(parents=True, exist_ok=True)
    if not any(data_dir.glob("*.pdf")):
        print(f"No PDF documents found in '{data_dir}'. Add PDFs and try again.")
        return

    documents = load_pdf_documents(data_dir)
    if not documents:
        print("No documents were successfully processed.")
        return

    print("Loading embedding model...")
    embeddings = HuggingFaceEmbeddings()
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=2000,
        chunk_overlap=500,
        length_function=len,
        separators=["\n\n", "\n", " ", ""],
    )
    chunks = splitter.split_documents(documents)
    print(f"Creating vector database from {len(chunks)} chunks...")
    vector_db_dir.mkdir(parents=True, exist_ok=True)
    Chroma.from_documents(
        documents=chunks,
        embedding=embeddings,
        persist_directory=str(vector_db_dir),
    )
    print(f"Vector database saved to '{vector_db_dir}'.")


def main() -> None:
    settings = get_settings()
    build_vector_store(settings.data_dir, settings.vector_db_dir)


if __name__ == "__main__":
    main()
