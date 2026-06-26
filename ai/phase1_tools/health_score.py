import subprocess
import json
from collections import defaultdict
from ai.phase1_tools.rca_engine import (
    investigate_pod
)

def get_pod_data():

    result = subprocess.run(
        ["kubectl", "get", "pods", "-A", "--no-headers"],
        capture_output=True,
        text=True,
        check=True
    )

    return result.stdout.splitlines()


def find_problematic_pods():

    pods = get_pod_data()

    problematic = []

    for line in pods:

        parts = line.split()

        if len(parts) < 5:
            continue

        namespace = parts[0]
        pod_name = parts[1]
        status = parts[3]

        try:
            restarts = int(parts[4])
        except:
            restarts = 0

        severity = None

        if status in [
            "CrashLoopBackOff",
            "ImagePullBackOff",
            "Error"
        ]:
            severity = "critical"

        elif restarts > 500:
            severity = "severe"

        elif restarts > 200:
            severity = "critical"

        elif restarts > 50:
            severity = "warning"

        if severity:

            problematic.append(
                {
                    "namespace": namespace,
                    "pod": pod_name,
                    "status": status,
                    "restarts": restarts,
                    "severity": severity,
                }
            )

    return problematic


def calculate_namespace_scores():

    pods = find_problematic_pods()

    namespace_scores = defaultdict(lambda: 100)

    for pod in pods:

        ns = pod["namespace"]

        if pod["severity"] == "warning":
            namespace_scores[ns] -= 10

        elif pod["severity"] == "critical":
            namespace_scores[ns] -= 30

        elif pod["severity"] == "severe":
            namespace_scores[ns] -= 50

    return dict(namespace_scores)


def calculate_cluster_score():

    scores = calculate_namespace_scores()

    if not scores:
        return 100

    return round(
        sum(scores.values()) / len(scores)
    )


def generate_rca_for_problematic_pods():

    problematic = find_problematic_pods()

    rca_reports = []

    for pod in problematic[:3]:

        try:

            rca = investigate_pod(
                pod["namespace"],
                pod["pod"]
            )

            clean_rca = (
                rca.replace("```json", "")
                .replace("```", "")
                .strip()
            )

            parsed_rca = json.loads(clean_rca)

            rca_reports.append(
                {
                    "namespace": pod["namespace"],
                    "pod": pod["pod"],
                    "rca": parsed_rca
                }
            )

        except Exception as e:

            rca_reports.append(
                {
                    "namespace": pod["namespace"],
                    "pod": pod["pod"],
                    "rca": f"Failed RCA: {str(e)}"
                }
            )

    return rca_reports


def get_cluster_health_report():

    problematic = find_problematic_pods()

    namespace_scores = calculate_namespace_scores()

    cluster_score = calculate_cluster_score()

    return {
        "cluster_score": cluster_score,
        "healthy": cluster_score >= 90,
        "namespace_health": namespace_scores,
        "problematic_pods": problematic,
        "rca_reports": []
    }
