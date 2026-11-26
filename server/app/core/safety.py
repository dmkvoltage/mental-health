import re

CRISIS_RESPONSE = (
    "I’m sorry you’re going through this. If you may act on these thoughts or are in "
    "immediate danger, contact your local emergency services or go to the nearest "
    "emergency department now. If possible, reach out to someone you trust and stay "
    "with them. A local crisis helpline can also provide immediate support."
)

SENSITIVE_KEYWORDS = (
    "suicide",
    "self-harm",
    "self harm",
    "kill myself",
    "kill",
    "end my life",
    "want to die",
    "hurting myself",
    "cutting",
    "overdose",
    "harm myself",
    "suicidal",
    "self injury",
    "self-injury",
    "self mutilation",
    "self-mutilation",
    "suicidal thoughts",
    "suicidal ideation",
    "harmful behaviors",
    "ending it all",
    "no reason to live",
    "can't go on",
    "want to disappear",
    "don't want to exist",
)


def contains_sensitive_topics(message: str) -> bool:
    message_lower = message.lower()
    return any(
        re.search(rf"\b{re.escape(keyword)}\b", message_lower)
        for keyword in SENSITIVE_KEYWORDS
    )
