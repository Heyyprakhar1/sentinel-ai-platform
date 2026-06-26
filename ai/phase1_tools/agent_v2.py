from langchain_ollama import ChatOllama
import json

from ai.phase1_tools.system_tools import (
    get_disk_usage,
    get_memory_usage,
    get_cpu_usage,
)

from ai.phase1_tools.k8s_tools import (
    get_pods,
    get_nodes,
    get_namespaces,
    get_deployments,
    cluster_health,
)

llm = ChatOllama(
    model="qwen2.5-coder:7b",
    temperature=0,
)

TOOLS = {

    "disk_usage": {
        "func": get_disk_usage,
        "description": "Get disk storage usage"
    },

    "memory_usage": {
        "func": get_memory_usage,
        "description": "Get RAM memory usage"
    },

    "cpu_usage": {
        "func": get_cpu_usage,
        "description": "Get CPU utilization"
    },

    "get_pods": {
        "func": get_pods,
        "description": "Get Kubernetes pods"
    },

    "get_nodes": {
        "func": get_nodes,
        "description": "Get Kubernetes nodes"
    },

    "get_namespaces": {
        "func": get_namespaces,
        "description": "Get Kubernetes namespaces"
    },

    "get_deployments": {
        "func": get_deployments,
        "description": "Get Kubernetes deployments"
    },

    "cluster_health": {
        "func": cluster_health,
        "description": "Check overall Kubernetes cluster health and detect failures"
    },
}


def choose_action(user_query):

    tool_prompt = ""

    for name, info in TOOLS.items():
        tool_prompt += f"- {name}: {info['description']}\n"

    prompt = f"""
You are a DevOps AI Agent.

Available Tools:

{tool_prompt}

Rules:
- Return ONLY tool name.
- No explanation.
- No markdown.
- No reasoning.

Examples:

User: Check disk health
disk_usage

User: Check memory health
memory_usage

User: Check CPU usage
cpu_usage

User: Show all pods
get_pods

User: List Kubernetes namespaces
get_namespaces

User: Show nodes
get_nodes

User: Show deployments
get_deployments

User: Check cluster health
cluster_health

User: {user_query}
"""

    response = llm.invoke(prompt)

    return response.content.strip()


def analyze_result(user_query, tool_result):

    prompt = f"""
User Request:
{user_query}

Tool Output:
{json.dumps(tool_result, indent=2)}

Provide:

1. Summary
2. Health Status
3. Recommendations

Keep it concise.
"""

    response = llm.invoke(prompt)

    return response.content


def run_agent(user_query):

    action = choose_action(user_query)

    print(f"\nSelected Action: {action}")

    if action not in TOOLS:
        return None, f"Unknown action selected: {action}"

    result = TOOLS[action]["func"]()

    final_answer = analyze_result(
        user_query,
        result
    )

    return result, final_answer


if __name__ == "__main__":

    question = input("\nAsk Agent: ")

    result, answer = run_agent(question)

    print("\nTool Output (JSON):\n")
    print(json.dumps(result, indent=2))

    print("\nFinal Answer:\n")
    print(answer)
