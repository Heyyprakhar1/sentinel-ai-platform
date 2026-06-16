import json
import time

from k8s_tools import (
    get_pod_logs,
    get_pod_description,
    get_namespace_events,
)

from langchain_ollama import ChatOllama


llm = ChatOllama(
    model="qwen2.5-coder:7b",
    temperature=0,
)


KEYWORDS = [
    "error",
    "failed",
    "crash",
    "backoff",
    "unauthorized",
    "forbidden",
    "denied",
    "timeout",
    "exception",
    "fatal",
    "oom",
    "evicted",
    "restart",
    "unhealthy",
]


def extract_relevant_lines(text, limit=60):

    if not text:
        return ""

    matched = []

    for line in text.splitlines():

        lower = line.lower()

        if any(
            keyword in lower
            for keyword in KEYWORDS
        ):
            matched.append(
                line.strip()
            )

    if matched:

        return "\n".join(
            matched[:limit]
        )

    return "\n".join(
        text.splitlines()[:40]
    )


def trim_text(
    text,
    max_chars=3000,
):

    if not text:
        return ""

    return text[:max_chars]


def build_prompt(
    logs,
    description,
    events,
):

    return f"""
You are a Senior Kubernetes SRE.

Analyze the failure.

Return ONLY valid JSON.

{{
  "root_cause": "",
  "severity": "",
  "confidence": "",
  "evidence": [],
  "recommended_fix": ""
}}

LOGS:
{logs}

DESCRIPTION:
{description}

EVENTS:
{events}
"""


def safe_json_response(text):

    if not text:

        return {
            "root_cause":
                "Empty model response",
            "severity":
                "unknown",
            "confidence":
                "0%",
            "evidence": [],
            "recommended_fix":
                "Retry RCA"
        }

    try:

        text = text.strip()

        text = text.replace(
            "```json",
            ""
        )

        text = text.replace(
            "```",
            ""
        )

        text = text.strip()

        start = text.find("{")
        end = text.rfind("}")

        if (
            start != -1
            and end != -1
        ):

            text = text[
                start:end + 1
            ]

        return json.loads(text)

    except Exception as e:

        return {
            "root_cause":
                text[:500],
            "severity":
                "unknown",
            "confidence":
                "low",
            "evidence": [],
            "recommended_fix":
                f"Unable to parse model output: {e}"
        }


def investigate_pod(
    namespace,
    pod,
):

    overall_start = time.time()

    print(
        f"\n[RCA] Starting RCA for "
        f"{namespace}/{pod}"
    )

    t1 = time.time()

    logs = get_pod_logs(
        namespace,
        pod,
    )

    print(
        "LOGS:",
        round(
            time.time() - t1,
            2
        ),
        "sec"
    )

    t2 = time.time()

    description = get_pod_description(
        namespace,
        pod,
    )

    print(
        "DESCRIPTION:",
        round(
            time.time() - t2,
            2
        ),
        "sec"
    )

    t3 = time.time()

    events = get_namespace_events(
        namespace,
    )

    print(
        "EVENTS:",
        round(
            time.time() - t3,
            2
        ),
        "sec"
    )

    logs = trim_text(
        extract_relevant_lines(
            logs
        )
    )

    description = trim_text(
        extract_relevant_lines(
            description
        )
    )

    events = trim_text(
        extract_relevant_lines(
            events
        )
    )

    prompt = build_prompt(
        logs,
        description,
        events,
    )

    t4 = time.time()

    response = llm.invoke(
        prompt
    )

    print(
        "LLM:",
        round(
            time.time() - t4,
            2
        ),
        "sec"
    )

    print(
        "TOTAL RCA:",
        round(
            time.time()
            - overall_start,
            2
        ),
        "sec"
    )

    return safe_json_response(
        response.content
    )
