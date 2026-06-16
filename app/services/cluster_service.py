import sys
from pathlib import Path

AI_PATH = (
    Path(__file__)
    .resolve()
    .parents[2]
    / "ai"
    / "phase1_tools"
)

if str(AI_PATH) not in sys.path:
    sys.path.append(str(AI_PATH))

from cluster_service import get_cluster_overview


def get_cluster_data():
    return get_cluster_overview()
