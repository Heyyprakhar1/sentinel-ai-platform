import subprocess
import json
import time

from health_score import (
    get_cluster_health_report
)


def get_namespaces():

    result = subprocess.run(
        [
            "kubectl",
            "get",
            "ns",
            "-o",
            "json"
        ],
        capture_output=True,
        text=True,
        check=True,
    )

    data = json.loads(result.stdout)

    return [
        ns["metadata"]["name"]
        for ns in data["items"]
    ]


def get_namespace_summary(
    namespace,
    namespace_health
):

    print(f"[DEBUG] Getting data for {namespace}")

    pods = subprocess.run(
        [
            "kubectl",
            "get",
            "pods",
            "-n",
            namespace,
            "--no-headers"
        ],
        capture_output=True,
        text=True,
    )

    deployments = subprocess.run(
        [
            "kubectl",
            "get",
            "deploy",
            "-n",
            namespace,
            "--no-headers"
        ],
        capture_output=True,
        text=True,
    )

    services = subprocess.run(
        [
            "kubectl",
            "get",
            "svc",
            "-n",
            namespace,
            "--no-headers"
        ],
        capture_output=True,
        text=True,
    )

    pod_count = len(
        pods.stdout.splitlines()
    )

    health_score = (
        namespace_health.get(
            namespace,
            100
        )
    )

    if health_score >= 90:
        status = "healthy"

    elif health_score >= 70:
        status = "warning"

    else:
        status = "critical"

    issues = max(
        0,
        (100 - health_score) // 10
    )

    print(f"[DEBUG] Completed {namespace}")

    return {
        "name": namespace,
        "pods": pod_count,
        "deployments": len(
            deployments.stdout.splitlines()
        ),
        "services": len(
            services.stdout.splitlines()
        ),
        "health_score": health_score,
        "status": status,
        "issues": issues,
    }


def get_cluster_overview():

    start = time.time()
    health_report = (
        get_cluster_health_report()
    )

    namespace_health = (
        health_report["namespace_health"]
    )

    print(
        "\n========== START CLUSTER SCAN ==========\n"
    )

    namespaces = get_namespaces()

    results = []

    for namespace in namespaces:

        print(
            f"[DEBUG] Processing namespace: {namespace}"
        )

        results.append(
            get_namespace_summary(
                namespace,
                namespace_health
            )
        )

    print(
        "\n========== CLUSTER SCAN COMPLETE ==========\n"
    )

    cluster_score = int(
        sum(
            ns["health_score"]
            for ns in results
        ) / len(results)
    )

    print(
        f"\nSCAN TIME = {round(time.time() - start, 2)} sec\n"
    )

    return {
        "cluster_name": "local-k3d",
        "cluster_score": cluster_score,
        "namespace_count": len(results),
        "namespaces": results,
    }


if __name__ == "__main__":

    print(
        json.dumps(
            get_cluster_overview(),
            indent=2
        )
    )
