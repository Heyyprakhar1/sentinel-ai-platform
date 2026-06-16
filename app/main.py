import time
from fastapi import FastAPI
from app.core.config import settings
from app.core.logging_config import logger
from app.api.routes import (
    health,
    metrics,
    alerts,
    recommendations,
    cluster,
    namespace,
)

START_TIME = time.time()

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="AI-Powered DevSecOps Monitoring Platform"
)

app.include_router(health.router)
app.include_router(metrics.router)
app.include_router(alerts.router)
app.include_router(recommendations.router)
app.include_router(cluster.router)
app.include_router(namespace.router)


@app.get("/status")
def status():

    return {
        "status": "running",
        "uptime_seconds": round(
            time.time() - START_TIME,
            2
        ),
        "timestamp": time.strftime(
            "%Y-%m-%dT%H:%M:%SZ",
            time.gmtime()
        )
    }


logger.info(
    f"SentinelAI starting | version={settings.APP_VERSION} | env={settings.ENVIRONMENT}"
)
