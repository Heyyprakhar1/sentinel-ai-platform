from langchain_ollama import ChatOllama

from ai.phase1_tools.tools import (
    get_disk_usage,
    get_memory_usage,
    get_cpu_usage,
    get_pods,
)

# =========================
# LLM
# =========================

llm = ChatOllama(
    model="qwen2.5-coder:7b",
    temperature=0,
)

# =========================
# Tool Registry
# =========================

TOOLS = {
    "disk_usage": {
        "func": get_disk_usage,
        "description": "Get disk storage usage and free space information"
    },

    "memory_usage": {
        "func": get_memory_usage,
        "description": "Get RAM memory usage information"
    },

    "cpu_usage": {
        "func": get_cpu_usage,
        "description": "Get CPU utilization percentage"
    },

    "get_pods": {
        "func": get_pods,
        "description": "Get Kubernetes pods running in the cluster"
    },
}


# =========================
# Tool Selection
# =========================

def choose_action(user_query: str):

    tool_prompt = ""

    for name, info in TOOLS.items():
        tool_prompt += f"- {name}: {info['description']}\n"

    prompt = f"""
You are an AI agent.

Available Tools:

{tool_prompt}

Rules:
- Return ONLY the action.
- No explanation.
- No reasoning.
- No thinking.
- No markdown.
- No extra text.

Examples:

User: Check disk health
Action: disk_usage

User: Check memory health
Action: memory_usage

User: Check RAM usage
Action: memory_usage

User: Check CPU utilization
Action: cpu_usage

User: Check processor load
Action: cpu_usage

User: Show all kubernetes pods
Action: get_pods

User: List pods in cluster
Action: get_pods

User: Get running pods
Action: get_pods

User: {user_query}
"""

    response = llm.invoke(prompt)

    action = response.content.strip()

    action = action.replace("Action:", "").strip()

    return action


# =========================
# Analysis Step
# =========================

def analyze_result(user_query, tool_result):

    prompt = f"""
User Request:
{user_query}

Tool Result:
{tool_result}

You are a DevOps Engineer.

Analyze the tool result and provide:

1. Summary
2. Health Status
3. Recommendation

Keep the response concise.
"""

    response = llm.invoke(prompt)

    return response.content


# =========================
# Agent Loop
# =========================

def run_agent(user_query):

    action = choose_action(user_query)

    print(f"\nSelected Action: {action}")

    if action not in TOOLS:
        return f"Unknown tool selected: {action}"

    result = TOOLS[action]["func"]()

    print(f"\nTool Output:\n{result}")

    final_answer = analyze_result(
        user_query=user_query,
        tool_result=result,
    )

    return final_answer


# =========================
# Main
# =========================

if __name__ == "__main__":

    question = input("\nAsk Agent: ")

    answer = run_agent(question)

    print("\nFinal Answer:\n")
    print(answer)
