import subprocess


def cluster_health():

    from ai.phase1_tools.health_score import (
        get_cluster_health_report
    )

    return get_cluster_health_report()


def get_pods():

    result = subprocess.run(
        ["kubectl", "get", "pods", "-A"],
        capture_output=True,
        text=True,
        check=True,
    )

    return result.stdout


def get_nodes():

    result = subprocess.run(
        ["kubectl", "get", "nodes"],
        capture_output=True,
        text=True,
        check=True,
    )

    return result.stdout


def get_namespaces():

    result = subprocess.run(
        ["kubectl", "get", "ns"],
        capture_output=True,
        text=True,
        check=True,
    )

    return result.stdout


def get_deployments():

    result = subprocess.run(
        ["kubectl", "get", "deploy", "-A"],
        capture_output=True,
        text=True,
        check=True,
    )

    return result.stdout


def get_pod_logs(namespace, pod):

    result = subprocess.run(
        [
            "kubectl",
            "logs",
            pod,
            "-n",
            namespace,
            "--tail=50"
        ],
        capture_output=True,
        text=True,
    )

    return result.stdout


def get_pod_description(namespace, pod):

    result = subprocess.run(
        [
            "kubectl",
            "describe",
            "pod",
            pod,
            "-n",
            namespace
        ],
        capture_output=True,
        text=True,
    )

    return result.stdout


def get_namespace_events(namespace):

    result = subprocess.run(
        [
            "kubectl",
            "get",
            "events",
            "-n",
            namespace,
            "--sort-by=.lastTimestamp"
        ],
        capture_output=True,
        text=True,
    )

    return result.stdout
