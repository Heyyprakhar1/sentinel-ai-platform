from health_score import find_problematic_pods
from rca_engine import investigate_pod


RCA_CACHE = {}


def get_namespace_details(namespace_name):

    problematic = find_problematic_pods()

    namespace_pods = []

    for pod in problematic:

        if pod["namespace"] == namespace_name:

            namespace_pods.append(
                {
                    "name": pod["pod"],
                    "status": pod["status"],
                    "restarts": pod["restarts"],
                    "severity": pod["severity"],
                }
            )

    return {
        "namespace": namespace_name,
        "problematic_pods": namespace_pods,
        "issue_count": len(namespace_pods),
    }


def get_namespace_rca(namespace_name):

    if namespace_name in RCA_CACHE:

        print(
            f"[CACHE HIT] {namespace_name}"
        )

        return RCA_CACHE[namespace_name]

    problematic = find_problematic_pods()

    namespace_pods = [
        pod
        for pod in problematic
        if pod["namespace"] == namespace_name
    ]

    if not namespace_pods:

        return {
            "namespace": namespace_name,
            "message": "No problematic pods found"
        }

    pod = namespace_pods[0]

    try:

        print(
            f"[RCA GENERATION] {namespace_name}"
        )

        rca = investigate_pod(
            namespace_name,
            pod["pod"]
        )

        result = {
            "namespace": namespace_name,
            "pod": pod["pod"],
            "analysis": rca
        }

        RCA_CACHE[
            namespace_name
        ] = result

        return result

    except Exception as e:

        return {
            "namespace": namespace_name,
            "error": str(e)
        }
