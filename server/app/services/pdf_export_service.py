import re
from datetime import datetime, timezone

from fpdf import FPDF
from fpdf.enums import XPos, YPos

from app.models.chat import ChatSession


def _remove_emojis(text: str) -> str:
    emoji_pattern = re.compile(
        "["
        "\U0001F600-\U0001F64F"
        "\U0001F300-\U0001F5FF"
        "\U0001F680-\U0001F6FF"
        "\U0001F1E0-\U0001F1FF"
        "\U00002702-\U000027B0"
        "\U0001F926-\U0001F937"
        "\U00010000-\U0010FFFF"
        "\u2640-\u2642"
        "\u2600-\u2B55"
        "\u200d"
        "\ufe0f"
        "]+",
        flags=re.UNICODE,
    )
    return emoji_pattern.sub("", text)


def create_chat_pdf(session: ChatSession) -> bytes:
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Helvetica", "B", 16)
    pdf.cell(
        0,
        10,
        "Mental Health Chatbot - Conversation History",
        new_x=XPos.LMARGIN,
        new_y=YPos.NEXT,
        align="C",
    )
    pdf.set_font("Helvetica", "", 10)
    pdf.cell(
        0,
        10,
        f"Date: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}",
        new_x=XPos.LMARGIN,
        new_y=YPos.NEXT,
        align="C",
    )
    pdf.ln(5)

    for message in session.messages:
        pdf.set_font("Helvetica", "B", 10)
        pdf.cell(
            0,
            8,
            message.role.capitalize(),
            new_x=XPos.LMARGIN,
            new_y=YPos.NEXT,
        )
        pdf.set_font("Helvetica", "", 10)
        content = _remove_emojis(message.content)
        content = content.encode("latin-1", errors="replace").decode("latin-1")
        pdf.multi_cell(0, 6, content)
        pdf.ln(3)

    return bytes(pdf.output())
