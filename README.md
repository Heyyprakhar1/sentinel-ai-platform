<div align="center">

# SentinelAI 🛡️

**AI-Powered Kubernetes Operations and DevSecOps Platform**

[![CI](https://github.com/Heyyprakhar1/sentinel-ai-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/Heyyprakhar1/sentinel-ai-platform/actions/workflows/ci.yml)
[![Security](https://github.com/Heyyprakhar1/sentinel-ai-platform/actions/workflows/security.yml/badge.svg)](https://github.com/Heyyprakhar1/sentinel-ai-platform/actions/workflows/security.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=Heyyprakhar1_sentinel-ai-platform&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=Heyyprakhar1_sentinel-ai-platform)

![Python](https://img.shields.io/badge/Python-3.12-3776AB?style=flat-square&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.136-009688?style=flat-square&logo=fastapi&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-multi--stage-2496ED?style=flat-square&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-K3d%20%2B%20EKS-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-1.15-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![React](https://img.shields.io/badge/React-18-61DAFB?style=flat-square&logo=react&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EKS%20%2B%20ECR-FF9900?style=flat-square&logo=amazonaws&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-Qwen2.5--Coder-black?style=flat-square)
![AIOps](https://img.shields.io/badge/AIOps-RCA%20Engine-FF6B35?style=flat-square)

</div>

---

## What Is This

SentinelAI is a production-style AI-powered Kubernetes Operations and DevSecOps platform — FastAPI backend, React dashboard, full Kubernetes deployment across dev/staging/prod environments, AWS EKS infrastructure via Terraform, and two independent CI pipelines running on every push.

The core of the platform is a **Kubernetes AI Operations Center**: it automatically discovers namespaces, calculates real-time cluster and namespace health scores, detects failure states (CrashLoopBackOff, ImagePullBackOff, excessive restarts), prioritizes incidents by severity, and runs an **AI Root Cause Analysis engine** that collects pod logs, descriptions, and events — then sends them to a local LLM (Qwen2.5-Coder via Ollama) to generate structured root cause analysis with recommended fixes.

On top of that: Z-score anomaly detection, a kube-prometheus-stack observability setup, OPA Gatekeeper admission control, and a React dashboard pulling live data from both the API and Prometheus.

This is not a monitoring dashboard that shows you CPU graphs. It answers: **what failed, which namespace is affected, how severe it is, and what to do next.**

Every decision — Kustomize overlay structure, probe design, multi-env separation, securityContext enforcement, OPA admission policies — reflects how production teams actually run services.

---

## What Makes SentinelAI Different

Most monitoring tools stop here:

```
CPU utilization: 74%
Memory usage: 61%
Pods running: 42/45
```

And leave the operator to figure out the rest.

SentinelAI extends the workflow:

```
Alert triggered
     │
     ▼
Pod Investigation  ─── Which pod? Which namespace? What state?
     │
     ▼
Log Collection     ─── Last 50 lines of pod logs
     │
     ▼
Event Analysis     ─── Namespace events sorted by timestamp
     │
     ▼
AI RCA             ─── Root cause, severity, confidence, evidence
     │
     ▼
Actionable Fix     ─── Recommended action, investigation steps
```

Operators don't ask "what's my CPU utilization?" during an incident. They ask: **what broke, which namespace is on fire, and what do I do in the next 5 minutes?**

Those are decision questions, not metric questions. SentinelAI is built around that distinction.

---

## Architecture

### Local — K3d

```
Developer Workstation (WSL2 / Ubuntu)
              │
              ▼
  FastAPI Backend (Python 3.12)
  ┌──────────────────────────────────────────────┐
  │  /health  /status       /metrics             │  ← Kubernetes probe-ready
  │  /alerts  /recommendation                    │  ← Anomaly layer
  │  /cluster /namespace/{ns} /namespace/{ns}/rca│  ← K8s Ops Center + AI RCA
  └──────────────────────────────────────────────┘
              │
              ▼
  Docker Image — multi-stage, non-root, python:3.12-slim
              │
              ▼
  K3d Cluster — 1 server + 2 agents
              │
              ▼
  Traefik Ingress → localhost:8080
              │
    ┌─────────┼──────────┐
    ▼         ▼          ▼
sentinelai  sentinelai  sentinelai
  -dev       -staging    -prod
 1 replica  2 replicas  3 replicas
```

### Production — AWS EKS via Terraform

```
GitHub Push
     │
     ├─────────────────────────────────────────────────────────────┐
     ▼                                                             ▼
CI Pipeline (ci.yml)                          Security Pipeline (security.yml)
├── pytest — 23 tests, 89% coverage           ├── bandit      — Python SAST
├── coverage gate — 70% minimum               ├── pip-audit   — Python CVEs
├── SonarCloud — static analysis              ├── npm audit   — JS vulnerabilities
└── docker-build                              ├── hadolint    — 3 Dockerfiles
     └── trivy-scan (CRITICAL = fail)         ├── shellcheck  — shell scripts
                                              └── gitleaks    — full git history
     │
     ▼
Amazon ECR
     │
     ▼
AWS EKS v1.35 (ap-south-1)
     ├── VPC — 2 public + 2 private subnets
     ├── Node Group — t3.medium × 2
     │
     ├── Admission Control
     │   ├── OPA Gatekeeper — 3 policies (non-root, resource limits, no latest tag)
     │   └── NetworkPolicy — zero trust ingress/egress
     │
     ├── Observability
     │   ├── kube-prometheus-stack (Helm)
     │   ├── ServiceMonitor — scrapes /metrics
     │   ├── PrometheusRule — CPU / Memory / Down alerts
     │   ├── Alertmanager — Slack routing
     │   ├── Grafana — cluster + app dashboards
     │   ├── HPA — scales 2–10 replicas on CPU/memory
     │   └── PDB — minAvailable: 1
     │
     ├── AI Layer
     │   ├── Z-score anomaly engine (20-reading rolling baseline)
     │   ├── Kubernetes Health Scoring Engine
     │   ├── Namespace Discovery Engine
     │   └── AI RCA Engine (Ollama + Qwen2.5-Coder)
     │
     └── React Dashboard
         ├── Live metrics + K8s pod panel via Prometheus API
         ├── Kubernetes AI Operations Center
         └── Namespace RCA View
```

### AI RCA Engine — Data Flow

```
React Dashboard
      │
      ▼
FastAPI Backend
      │
      ├── Metrics Engine          ← Z-score anomaly detection
      ├── Anomaly Detection       ← 20-reading rolling baseline
      ├── Cluster Health Engine   ← Cluster score calculation
      ├── Namespace Health Engine ← Per-namespace score + issue tracking
      └── RCA Engine              ← Evidence collection + LLM invocation
            │
            ▼
          Ollama
            │
            ▼
      Qwen2.5-Coder:7b
            │
            ▼
  Kubernetes Logs / Events / Pod Metadata
```

---

## Tech Stack

| Layer | Technology | Status |
|---|---|---|
| Backend | Python 3.12, FastAPI 0.136, Uvicorn | ✅ |
| Containerization | Docker — multi-stage, non-root, python:3.12-slim | ✅ |
| Local Dev Stack | Docker Compose — backend + frontend + Prometheus + Grafana + Alertmanager | ✅ |
| Orchestration | Kubernetes — K3d (local), AWS EKS v1.35 (prod) | ✅ |
| Config Management | Kustomize — base + dev/staging/prod overlays | ✅ |
| Automation | Makefile | ✅ |
| CI Pipeline | GitHub Actions — pytest + SonarCloud + Trivy | ✅ |
| Security Pipeline | GitHub Actions — Bandit + pip-audit + npm audit + Hadolint + ShellCheck + Gitleaks | ✅ |
| Code Quality | SonarCloud — quality gate | ✅ |
| Image Security | Trivy — CRITICAL CVE fail gate | ✅ |
| Python SAST | Bandit — 0 medium/high issues | ✅ |
| Dependency Audit | pip-audit (Python) + npm audit (JS) | ✅ |
| Dockerfile Lint | Hadolint — backend + 2 frontend Dockerfiles | ✅ |
| Shell Analysis | ShellCheck | ✅ |
| Secret Scanning | Gitleaks — full git history on every push | ✅ |
| Admission Control | OPA Gatekeeper — 3 Rego policies | ✅ |
| Infrastructure as Code | Terraform v1.15 — VPC, EKS, ECR, IAM, S3 state | ✅ |
| Container Registry | Amazon ECR | ✅ |
| Metrics | Prometheus + ServiceMonitor | ✅ |
| Dashboards | Grafana — cluster overview + custom app dashboard | ✅ |
| Alerting | PrometheusRule + Alertmanager — Slack routing | ✅ |
| Autoscaling | HPA — CPU 70% / Memory 80%, min 2 / max 10 | ✅ |
| Resilience | PodDisruptionBudget — minAvailable: 1 | ✅ |
| Network Security | NetworkPolicy — zero trust | ✅ |
| Pod Security | securityContext — runAsNonRoot, readOnlyRootFilesystem, no privilege escalation | ✅ |
| Anomaly Detection | Z-score engine (20-reading rolling baseline) | ✅ |
| Kubernetes Ops | Namespace Discovery + Cluster/Namespace Health Scoring | ✅ |
| AI Local LLM | Ollama — local inference server | ✅ |
| AI Model | Qwen2.5-Coder:7b — structured RCA generation | ✅ |
| AI RCA Engine | Log + Event + Description analysis → structured JSON RCA | ✅ |
| AIOps | Incident prioritization + remediation recommendations | ✅ |
| Frontend | React 18 + Vite — live metrics + K8s Operations Center dashboard | ✅ |
| GitOps | ArgoCD — continuous deployment | 🔄 In Progress |

---

## Project Structure

```
sentinel-ai-platform/
│
├── ai/                               # AI engines — run standalone or via API
│   ├── phase1_tools/
│   │   ├── agent_v1.py               # Initial agent — system metrics + K8s tools
│   │   ├── agent_v2.py               # Enhanced agent — cluster health + RCA
│   │   ├── cluster_service.py        # Cluster-level health aggregation
│   │   ├── health_score.py           # Health scoring engine — namespace + cluster
│   │   ├── k8s_tools.py              # kubectl wrappers — logs, describe, events
│   │   ├── langchain_agent.py        # LangChain agent scaffolding
│   │   ├── rca_engine.py             # AI RCA — Ollama + Qwen2.5-Coder invocation
│   │   ├── system_tools.py           # CPU, memory, disk tools
│   │   └── tools.py                  # Tool registry
│   └── requirements.txt              # AI layer deps (langchain-ollama)
│
├── app/                              # FastAPI application
│   ├── main.py                       # App entry point + route registration
│   ├── api/routes/
│   │   ├── health.py                 # GET /health  ← liveness probe
│   │   ├── metrics.py                # GET /metrics ← Prometheus scrape
│   │   ├── alerts.py                 # GET /alerts
│   │   ├── recommendations.py        # GET /recommendation ← Z-score AI layer
│   │   ├── cluster.py                # GET /cluster ← cluster health score + pod list
│   │   └── namespace.py              # GET /namespace/{ns} + /namespace/{ns}/rca
│   ├── core/
│   │   ├── config.py                 # Pydantic-settings env config
│   │   └── logging_config.py         # Structured JSON stdout logging
│   ├── models/schemas.py             # Pydantic data contracts
│   └── services/
│       ├── alert_service.py          # UUID alert IDs, real CPU readings
│       ├── recommendation_service.py
│       ├── anomaly_detector.py       # Z-score engine — 20-reading baseline
│       ├── cluster_service.py        # Cluster health aggregation service
│       └── namespace_service.py      # Namespace discovery + RCA caching
│
├── frontend/                         # React + Vite dashboard
│   ├── src/
│   │   ├── components/
│   │   │   ├── StatusBar.jsx         # Live health status bar
│   │   │   ├── MetricCard.jsx        # CPU / Memory / Uptime cards
│   │   │   ├── MetricsChart.jsx      # 2.5min rolling time-series
│   │   │   ├── AlertsFeed.jsx        # Live alert feed
│   │   │   ├── AnomalyPanel.jsx      # Z-score gauge + recommendation
│   │   │   ├── StatusDetails.jsx     # Service status panel
│   │   │   ├── K8sPanel.jsx          # Kubernetes AI Operations Center
│   │   │   ├── NamespaceCard.jsx     # Per-namespace health card + issue count
│   │   │   └── NamespaceDetails.jsx  # Drill-down: namespace → pods → AI RCA
│   │   ├── hooks/usePolling.js       # Polling + history state hooks
│   │   └── lib/api.js                # API client + Prometheus query builder
│   ├── Dockerfile                    # K8s deploy — nginx:1.27-alpine, non-root
│   ├── Dockerfile.compose            # Docker Compose variant
│   ├── nginx.conf                    # Reverse proxy config
│   └── package-lock.json             # Pinned deps — deterministic CI installs
│
├── k8s/
│   ├── namespaces.yaml               # dev / staging / prod
│   ├── base/                         # Shared manifests
│   │   ├── deployment.yaml           # securityContext — non-root, readOnly FS
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml                  # CPU 70% / Memory 80%, max 10 replicas
│   │   ├── pdb.yaml                  # minAvailable: 1
│   │   ├── networkpolicy.yaml        # Zero trust
│   │   └── kustomization.yaml
│   ├── overlays/
│   │   ├── dev/                      # namePrefix: dev-, 1 replica, DEBUG, Never pull
│   │   ├── staging/                  # namePrefix: staging-, 2 replicas, INFO
│   │   └── prod/                     # namePrefix: prod-, 3 replicas, WARNING, Always
│   ├── argocd/
│   │   ├── appset.yaml               # ApplicationSet — multi-env GitOps
│   │   └── namespace.yaml
│   ├── frontend/dashboard.yaml       # Frontend Deployment + Service + Ingress
│   ├── gatekeeper/
│   │   ├── templates/                # ConstraintTemplates (Rego)
│   │   │   ├── require-nonroot.yaml
│   │   │   ├── require-resource-limits.yaml
│   │   │   └── ban-latest-tag.yaml
│   │   └── constraints/
│   └── monitoring/
│       ├── servicemonitor.yaml       # Prometheus scrape config
│       ├── prometheusrule.yaml       # CPU / Memory / Down alert rules
│       └── alertmanager.yaml         # Slack routing config
│
├── terraform/
│   ├── backend.tf                    # S3 remote state + DynamoDB lock
│   ├── vpc.tf                        # VPC, public/private subnets, IGW, NAT
│   ├── iam.tf                        # EKS cluster + node group IAM roles
│   ├── eks.tf                        # EKS cluster v1.35 + managed node group
│   ├── ecr.tf                        # ECR repo + lifecycle policy
│   ├── variables.tf
│   └── outputs.tf
│
├── tests/
│   ├── test_health.py                # 5 tests — health endpoint
│   ├── test_status.py                # 4 tests — status endpoint
│   ├── test_alerts.py                # 4 tests — alerts + UUID IDs
│   ├── test_recommendations.py       # 8 tests — Z-score + anomaly scenarios
│   └── test_api.py                   # 2 smoke tests — all endpoints reachable
│
├── monitoring/compose/               # Prometheus + Alertmanager configs for Compose
├── scripts/
│   ├── k3d-setup.sh                  # Cluster setup + teardown
│   ├── setup-all.sh                  # Full stack bootstrap
│   └── teardown-all.sh               # Full stack teardown
├── docs/
│   ├── architecture.md
│   ├── setup.md
│   └── screenshots/                  # Dashboard screenshots
│       ├── dashboard-overview.png
│       ├── k8s-operations-center.png
│       └── ai-rca.png
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── security.yml
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/bug_report.md
│
├── docker-compose.yml
├── Dockerfile
├── Makefile
├── requirements.txt
├── .env.example
├── .gitleaksignore
└── .dockerignore
```

---

## Kubernetes AI Operations Center

The Operations Center is the primary interface of SentinelAI. It moves past metrics and answers operator questions directly.

**Cluster Score** — A single 0–100 score representing the overall health of the cluster. Calculated as the mean of all namespace scores. Score ≥ 90 = healthy. Below 90 = degraded.

**Namespace Health** — Each namespace gets its own score, reduced by active failure states:

| Failure State | Score Penalty |
|---|---|
| CrashLoopBackOff / ImagePullBackOff / Error | −30 |
| Restart count > 200 | −30 |
| Restart count > 500 | −50 |
| Restart count > 50 | −10 |

**Problematic Pod Detection** — Scans all pods across all namespaces. Flags pods by severity (critical → severe → warning) based on failure state and restart count.

**Issue Count Tracking** — Each namespace card in the dashboard shows the number of active issues, the most critical failure state, and a direct link to the RCA panel.

**AI RCA Generation** — RCA is triggered only for namespaces with active issues. The engine collects evidence, calls the LLM, and returns a structured JSON report. Results are cached to avoid repeated LLM calls for the same pod in the same state.

**Troubleshooting Workflow**:

```
Dashboard → Cluster Score (degraded)
         → Namespace Card (issue count)
         → Namespace Detail (problematic pods)
         → AI RCA Panel (root cause + fix)
```

---

## AI Root Cause Analysis Engine

The RCA engine takes a failing pod and produces a structured diagnosis. No manual log grepping required.

### Workflow

```
1. Detect problematic pod
        │   kubectl get pods -A --no-headers
        │   Filter: CrashLoopBackOff / ImagePullBackOff / Error / high restarts
        ▼
2. Collect pod logs
        │   kubectl logs <pod> -n <namespace> --tail=50
        ▼
3. Collect pod description
        │   kubectl describe pod <pod> -n <namespace>
        ▼
4. Collect namespace events
        │   kubectl get events -n <namespace> --sort-by=.lastTimestamp
        ▼
5. Reduce context
        │   Combine logs + description + events into a single prompt
        ▼
6. Send to Ollama
        │   ChatOllama(model="qwen2.5-coder:7b", temperature=0)
        ▼
7. Generate structured RCA
        │   Returns valid JSON — no markdown, no explanation
        ▼
8. Cache result
        │   Avoids repeated LLM calls for same pod
        ▼
9. Display in dashboard
           NamespaceDetails.jsx → AI RCA Panel
```

### RCA Output Schema

```json
{
  "root_cause": "ApplicationSet CRD missing from cluster — controller cannot find the resource definition",
  "severity": "critical",
  "confidence": "high",
  "evidence": [
    "no matches for kind ApplicationSet in version argoproj.io/v1alpha1",
    "restmapper failure on startup",
    "repeated CrashLoopBackOff — 900+ restarts"
  ],
  "recommended_fix": "Install ApplicationSet CRD: kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/applicationset-crd.yaml"
}
```

---

## Local AI Setup

The AI RCA Engine requires Ollama running locally. Without it, `/namespace/{ns}/rca` returns a connection error.

### Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Pull the model

```bash
ollama pull qwen2.5-coder:7b
```

### Verify the model is available

```bash
ollama list
# NAME                    ID              SIZE    MODIFIED
# qwen2.5-coder:7b        ...             4.7 GB  ...
```

### Start the Ollama server

```bash
ollama serve
```

Ollama serves on `http://localhost:11434` by default.

### Verify it's running

```bash
curl http://localhost:11434/api/tags
```

You should see the model listed in the response. Once this returns successfully, SentinelAI's RCA engine can call it.

> **Note:** RCA generation for a single pod typically takes 10–30 seconds depending on hardware. Results are cached — subsequent requests for the same pod return instantly.

---

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Python | 3.12+ | Backend runtime |
| Docker | 20.0+ | Image builds |
| kubectl | 1.28+ | Cluster management |
| k3d | 5.0+ | Local Kubernetes |
| Helm | 3.0+ | Prometheus stack |
| Node.js | 18+ | Frontend dev server |
| Ollama | latest | Local LLM inference (AI RCA) |
| Terraform | 1.10+ | AWS infra (optional) |
| AWS CLI | 2.0+ | EKS access (optional) |

---

## Quickstart — Docker Compose

Fastest way to run the full stack locally. No Kubernetes needed.

```bash
git clone https://github.com/Heyyprakhar1/sentinel-ai-platform.git
cd sentinel-ai-platform

cp .env.example .env
# Edit .env — set GRAFANA_ADMIN_PASSWORD

docker compose up -d
docker compose ps
```

| Service | URL |
|---|---|
| Backend API | http://localhost:8000 |
| Swagger UI | http://localhost:8000/docs |
| Frontend Dashboard | http://localhost:5173 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| Alertmanager | http://localhost:9093 |

```bash
docker compose logs -f sentinelai-backend
docker compose down
```

> The AI RCA endpoints require Ollama running separately. Start it with `ollama serve` before hitting `/namespace/{ns}/rca`.

---

## Running the Platform

### Path 1 — Backend Only

For API development and testing without a Kubernetes cluster:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

uvicorn app.main:app --reload --port 8000

# Verify
curl http://localhost:8000/health
curl http://localhost:8000/alerts
curl http://localhost:8000/recommendation
```

### Path 2 — Backend + Frontend

Full local development stack without Kubernetes:

```bash
# Terminal 1 — backend
uvicorn app.main:app --reload --port 8000

# Terminal 2 — frontend
cd frontend && npm install
VITE_API_URL=http://localhost:8000 npm run dev
# Open http://localhost:5173
```

### Path 3 — Full Kubernetes + AI Stack

Full production-like stack with K3d, Prometheus, and Ollama:

```bash
# 1. Start Ollama (required for RCA)
ollama serve &

# 2. Build and load image
make build
make cluster-up
make import-image

# 3. Deploy all environments
kubectl apply -f k8s/namespaces.yaml
make deploy-all
make status

# 4. Port-forward backend
kubectl port-forward svc/dev-sentinelai-service 8001:80 -n sentinelai-dev

# 5. Start frontend
cd frontend && npm install
VITE_API_URL=http://localhost:8001 npm run dev

# 6. Test RCA
curl http://localhost:8001/cluster | python3 -m json.tool
curl http://localhost:8001/namespace/argocd | python3 -m json.tool
curl http://localhost:8001/namespace/argocd/rca | python3 -m json.tool
```

---

## Local Kubernetes Setup

### 1. Clone + Python env

```bash
git clone https://github.com/Heyyprakhar1/sentinel-ai-platform.git
cd sentinel-ai-platform

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Run tests

```bash
pytest tests/ -v
# 23 passed

pytest tests/ --cov=app --cov-report=term
# 89% coverage
```

### 3. Build + cluster

```bash
make build
make cluster-up
make import-image
```

### 4. Deploy all environments

```bash
kubectl apply -f k8s/namespaces.yaml
make deploy-all
make status
```

### 5. Verify

```bash
curl http://localhost:8080/health
curl http://localhost:8080/alerts
curl http://localhost:8080/recommendation
curl http://localhost:8080/cluster
```

---

## Frontend Dashboard

```bash
# Terminal 1 — backend
kubectl port-forward svc/dev-sentinelai-service 8001:80 -n sentinelai-dev

# Terminal 2 — dashboard
cd frontend && npm install
VITE_API_URL=http://localhost:8001 npm run dev
# Open http://localhost:5173
```

For K8s pod metrics in the dashboard:

```bash
# Terminal 3 — Prometheus
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring

# Restart frontend with both vars
VITE_API_URL=http://localhost:8001 VITE_PROM_URL=http://localhost:9090 npm run dev
```

The `K8sPanel.jsx` now serves as the **Kubernetes AI Operations Center** — it renders namespace health cards (`NamespaceCard.jsx`), cluster score, and drill-down views (`NamespaceDetails.jsx`) with embedded AI RCA panels.

---

## Observability Stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=sentinel@123 \
  --set prometheus.prometheusSpec.retention=7d

kubectl apply -f k8s/monitoring/servicemonitor.yaml
kubectl apply -f k8s/monitoring/prometheusrule.yaml
kubectl apply -f k8s/monitoring/alertmanager.yaml
```

| Tool | Access |
|---|---|
| Grafana | `kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring` → http://localhost:3000 |
| Prometheus | `kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring` → http://localhost:9090 |

Grafana dashboard IDs to import: `15757` (cluster overview), `1860` (node exporter), `6417` (pod resources).

---

## AWS EKS Deployment

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

aws eks update-kubeconfig --region ap-south-1 --name sentinelai-cluster
kubectl get nodes
```

```bash
# Teardown
terraform destroy -auto-approve
```

---

## CI/CD Pipelines

Two pipelines run in parallel on every push to `main`. Both must pass — nothing merges if either fails.

### CI Pipeline (`ci.yml`)

```
push to main
     │
     ▼
  test
  ├── Python 3.12
  ├── pytest — 23 tests
  └── coverage gate — 70% minimum (currently 89%)
     │
     ├──────────────────┐
     ▼                  ▼
sonarcloud         docker-build
quality gate            │
                        ▼
                   trivy-scan
                   CRITICAL CVE = fail
```

### Security Pipeline (`security.yml`)

```
push to main
     │
     ├── python-security  →  bandit (app/)  +  pip-audit (requirements.txt)
     ├── js-security      →  npm audit --audit-level=high (frontend/)
     ├── dockerfile-lint  →  hadolint (Dockerfile, frontend/Dockerfile, frontend/Dockerfile.compose)
     ├── shell-check      →  shellcheck (scripts/)
     └── secret-scan      →  gitleaks (full git history, fetch-depth: 0)
```

---

## API Reference

### Core Endpoints

| Endpoint | Method | Description | Kubernetes Role |
|---|---|---|---|
| `/health` | GET | App name, version, uptime | Liveness probe |
| `/status` | GET | Runtime status, environment | Readiness probe |
| `/metrics` | GET | Prometheus-format metrics | Scrape target |
| `/alerts` | GET | Active alerts with UUID IDs + severity | Core workload |
| `/recommendation` | GET | Z-score anomaly score + recommendation | Anomaly layer |

### Kubernetes Operations Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/cluster` | GET | Cluster health score, namespace scores, problematic pods |
| `/namespace/{namespace}` | GET | Health score + active issues for a specific namespace |
| `/namespace/{namespace}/rca` | GET | AI-generated RCA for the most critical pod in a namespace |

#### `GET /cluster`

Returns the full cluster health report — scores, problematic pods, and namespace breakdown.

```bash
curl http://localhost:8000/cluster | python3 -m json.tool
```

```json
{
  "cluster_score": 62,
  "healthy": false,
  "namespace_health": {
    "argocd": 40,
    "kube-system": 90,
    "monitoring": 100
  },
  "problematic_pods": [
    {
      "namespace": "argocd",
      "pod": "argocd-applicationset-controller-xxxxx",
      "status": "CrashLoopBackOff",
      "restarts": 924,
      "severity": "severe"
    }
  ]
}
```

#### `GET /namespace/{namespace}`

Returns health score and issue summary for a specific namespace.

```bash
curl http://localhost:8000/namespace/argocd | python3 -m json.tool
```

```json
{
  "namespace": "argocd",
  "health_score": 40,
  "issue_count": 1,
  "problematic_pods": [
    {
      "pod": "argocd-applicationset-controller-xxxxx",
      "status": "CrashLoopBackOff",
      "restarts": 924,
      "severity": "severe"
    }
  ]
}
```

#### `GET /namespace/{namespace}/rca`

Runs AI root cause analysis for the most critical pod in the namespace. Requires Ollama running on `localhost:11434`.

```bash
curl http://localhost:8000/namespace/argocd/rca | python3 -m json.tool
```

```json
{
  "namespace": "argocd",
  "pod": "argocd-applicationset-controller-xxxxx",
  "rca": {
    "root_cause": "ApplicationSet CRD missing — controller cannot find resource definition on startup",
    "severity": "crical",
    "confidence": "high",
    "evidence": [
      "no matches for kind ApplicationSet in version argoproj.io/v1alpha1",
      "failed to get REST mapping for resource",
      "repeated controller startup failure — 924 restarts"
    ],
    "recommended_fix": "kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/applicationset-crd.yaml"
  }
}
```

### Quick reference

```bash
curl http://localhost:8000/health | python3 -m json.tool
curl http://localhost:8000/recomndation | python3 -m json.tool
curl http://localhost:8000/cluster | python3 -m json.tool
curl http://localhost:8000/namespace/argocd/rca | python3 -m json.tool
```

---

## How the Anomaly Detection Works

The `/recommendation` endpoint runs a Z-score engine on a rolling window of the last 20 metric readings.

```
Reading arrives
     │
     ▼
Buffer (max 20 readings)
     │
     ├── < 5 readings → warming_up: true, confidence: low
     │
     └── ≥ 5 readings → calculate mean + st           │
               ▼
          Z-score = (current - mean) / std_dev
               │
               ├── Z > 3.0 → severity: critical
               ├── Z > 2.0 → severity: warning
               └── Z ≤ 2.0 → severity: info
```

Alert IDs are UUID-based (`alert-cpu-critical-a3f9b2c1`) — safe to pipe into PagerDuty, OpsGenie, or any deduplication system without collision.

---

## Example AI Investigations

### Example 1 — ArgoCD ApplicationSet Controller

**Names:** `argocd`
**Pod:** `argocd-applicationset-controller-xxxxx`
**State:** CrashLoopBackOff — 924 restarts

**Evidence collected by SentinelAI:**

```
# From pod logs (--tail=50)
time="..." level=fatal msg="no matches for kind \"ApplicationSet\" in version \"argoproj.io/v1alpha1\""
time="..." level=error msg="failed to get REST mapping"

# From namespace events
LAST SEEN   TYPE      REASON    OBJECT                              MESSAGE
2m          Warning   BackOff   pod/argocd-applicationset-...       Bacoff restarting failed container
```

**SentinelAI RCA output:**

```json
{
  "root_cause": "ApplicationSet CRD is not installed on the cluster. The controller attempts to register the CRD watch on startup and fails immediately when the API group is not found.",
  "severity": "critical",
  "confidence": "high",
  "evidence": [
    "no matches for kind ApplicationSet in version argoproj.io/v1alpha1",
    "REST mapping failure on every startup attempt",
    "924 restarts — no recovery between crashes"
  ],
 recommended_fix": "kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/applicationset-crd.yaml"
}
```

---

### Example 2 — kube-system Networking Issue

**Namespace:** `kube-system`
**Pod:** `coredns-xxxxx`
**State:** Error / high restart count

**Evidence collected by SentinelAI:**

```
# From pod description
Readiness: http-get http://:8080/ready delay=0s timeout=1s period=10s
Last State: Terminated Reason: Error Exit Code: 2

# From namespace events
Warning   Unhethy   pod/coredns-xxx   Readiness probe failed: Get "http://...": context deadline exceeded
```

**SentinelAI RCA output:**

```json
{
  "root_cause": "CoreDNS readiness probe is timing out — likely a network policy blocking probe traffic from the kubelet to port 8080, or a resource constraint preventing the container from binding to the port in time.",
  "severity": "critical",
  "confidence": "medium",
  "evidence": [
    "readiness probe context deadline exceeded",
    "exit code 2 — process exited werror",
    "consistent failure pattern — not a transient crash"
  ],
  "recommended_fix": "Check NetworkPolicy in kube-system — ensure kubelet IP range is allowed to reach port 8080. Also verify CPU/memory limits are not causing slow startup."
}
```

---

## Dashboard Screenshots

> Screenshots are located in `docs/screenshots/`. Add them after your first local run.

**`docs/screenshots/dashboard-overview.png`**
Main dashboard — StatusBar, MetricCard (CPU/Memory/Uptime), rolling MetricsChart, AlertsF-score AnomalyPanel.

**`docs/screenshots/k8s-operations-center.png`**
Kubernetes AI Operations Center — cluster health score at top, namespace health cards with issue counts, severity badges (CRITICAL / HIGH / MEDIUM / LOW).

**`docs/screenshots/ai-rca.png`**
Namespace detail view — NamespaceDetails panel showing the problematic pod, collected evidence (logs, events), and the AI-generated root cause, confidence score, and recommended fix.

---

## Alert Rules

| Alert | Fires When | Severity |
|---|---|
| `SentinelAIHighCPU` | CPU > 80% for 2 minutes | warning |
| `SentinelAIHighMemory` | Memory > 85% for 2 minutes | critical |
| `SentinelAIDown` | Pod unreachable for 1 minute | critical |

Routes to Slack via Alertmanager. Update the webhook URL in `k8s/monitoring/alertmanager.yaml` before applying.

---

## OPA Gatekeeper Policies

Enforced at admission time — any manifest violating these is rejected at `kubectl apply`.

| Policy | Rule |
|---|---|
| `require-non-root` | All containers must run as noroot user |
| `require-resource-limits` | CPU + memory limits required on every container |
| `ban-latest-tag` | `:latest` image tag rejected |

---

## Security Hardening

| Area | Implementation |
|---|---|
| Container user | Non-root (`sentinel` user, UID 1000) |
| K8s pod spec | `runAsNonRoot: true`, `readOnlyRootFilesystem: true`, `allowPrivilegeEscalation: false` |
| Secrets | No secrets in code — env vars + GitHub Secrets only |
| Python code | Bandit SAST — 0 medium/high findings |
| Python depsip-audit — CVEs fixed (starlette 1.0.0 → 1.0.1) |
| JS deps | npm audit — 0 high/critical vulnerabilities |
| Dockerfiles | Hadolint — all 3 Dockerfiles clean |
| Shell scripts | ShellCheck — 0 warnings |
| Git history | Gitleaks — full history scanned on every push |
| Image scanning | Trivy — CRITICAL CVEs block registry push |
| Alert IDs | UUID-based — deduplication-safe |

---

## Environment Matrix

| Property | Dev | Staging | Prod |
|---|---|---|---|
| Namespace | `sentinelai-dev` | `sentinelai-staging` | `sentinelai-prod` |
| Replicas | 1 | 2 | 3 |
| Log Level | DEBUG | INFO | WARNING |
| CPU Request / Limit | 50m / 100m | 100m / 200m | 200m / 400m |
| Memory Request / Limit | 64Mi / 128Mi | 128Mi / 256Mi | 256Mi / 512Mi |
| Image Pull Policy | Never | IfNotPresent | Always |

---

## Makefile Commands

```bash
# Docker
make build            # Build sentinelai:1.0.0
make run              # Run container on port 8000
make stop             # Stop and remove container

# Deploy
make deploy-dev       # Apply dev overlay
make deploy-staging   # Apply staging overlay
make deploy-prod      # Apply prod overlay
make deploy-all       # Apply namespaces + all overlays

# Observe
make status           # Show pods across all 3 envs
make logs-dev         # Tail dev pod logs

# Cluster
make cluster-up       # Create K3d cluster
make cluster-down     # Delete K3d cluster
make import-image     # Load Docker image into K3d

# Cleanup
make clean            # Delete all deployments
```

---

## Troubleshooting

**Dashboard shows "CONNECTING..."**
```bash
kubectl port-forward svc/dev-sentinelai-service 8001:80 -n sentinelai-dev
# Restart frontend with VITE_API_URL=http://localhost:8001
```

**K8s panel shows "Loading pod data..."**
```bash
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
```

**`/cluster` or `/namespace/{ns}` returns 500**
```bash
# kubectl must be configured and pointing at a running cluster
kubectl config current-context
kubectl get pods -A --no-headers
# If this fails, the health scoring engine can't run
```

**`/namespace/{ns}/rca` returns connection error**
```bash
# Ollama must be running
ollama serve
curl http://localhost:11434/api/tags
# If model is missing: ollama pull qwen2.5-coder:7b
```

**RCA returns `"Failed RCA: ..."`**
The engine caught an exception during evidence collection or LLM invocation. Common causes: pod no longer exists (it recovered), Ollama not running, or the LLM returned non-JSON output. Check `ollama serve` output for errors.

**Pods stuck in Pending after Helm install**
```bash
kubectl get pvc -n monitoring
kubectl describe pod <pod-name> -n monitoring
# Usually a storage class issue on K3d — PVC can't bind
```

**OPA blocks your manifest**
The rejection message names the exact policy that failed. Either add resource limits, set `runAsNonRoot`, or fix the image tag.

**`warming_up: true` in /recommendation**
Expected. Z-score engine needs 5 readings (~30s of uptime) before baseline is ready.

**Gitleaks fails on CI**
Check `itleaksignore` — if you've added new example credentials, document and suppress them there. Never suppress without a comment explaining why.

**Terraform apply fails**
Your AWS CLI user needs: `eks:*`, `ec2:*`, `iam:PassRole`, `iam:CreateRole`, `ecr:*`, `s3:*`.

---

## Roadmap

| Phase | What | Status |
|---|---|---|
| 1 | FastAPI backend — endpoints, schemas, typed service layer | ✅ Complete |
| 2 | Docker — multi-stage, non-root, python:3.12-slim | ✅ Complete |
| 3 | Local Kubernetes — K3d, mstomize, Traefik Ingress | ✅ Complete |
| 4 | Repo structure — Makefile, GitHub templates, PR/issue templates | ✅ Complete |
| 5 | CI pipeline — pytest, SonarCloud quality gate, Trivy CVE gate | ✅ Complete |
| 6 | DevSecOps — OPA Gatekeeper (3 Rego policies), NetworkPolicy | ✅ Complete |
| 7 | AWS EKS via Terraform — VPC, EKS, ECR, IAM, S3 remote state | ✅ Complete |
| 8 | Observability — kube-prometheus-stack, Grafana, Alertmanager, HPA, PDB | ✅ Complete |
| 9 | Anomaly Detection — engine, dynamic recommendations | ✅ Complete |
| 10 | React dashboard — live metrics, anomaly panel, K8s pod panel | ✅ Complete |
| 11 | Security hardening — securityContext, UUID alert IDs, CVE fixes, full security pipeline | ✅ Complete |
| 12 | Kubernetes Health Scoring Engine — cluster score + namespace scores | ✅ Complete |
| 13 | AI RCA Engine — Ollama + Qwen2.5-Coder + evidence collection | ✅ Complete |
| 14 | Kubernetes AI Operations Center — namespace cards + drill-down + RCA pan ✅ Complete |
| 15 | GitOps — ArgoCD ApplicationSet, multi-env continuous deployment | 🔄 In Progress |
| 16 | Multi-model RCA — GPT-4o / Claude / Gemini fallback chain | 🗺️ Planned |
| 17 | Historical RCA storage — PostgreSQL incident log | 🗺️ Planned |
| 18 | Incident knowledge base — search previous RCA reports | 🗺️ Planned |
| 19 | Vector search — semantic similarity across past incidents | 🗺️ Planned |
| 20 | Slack RCA delivery — post RCA summaries to incident channels | 🗺️ Planned |
| 21 | Automated runbook generation — LLM-generated step-by-step fixes | 🗺️ Planned |
| 22 | GitOps-triggered remediation — ArgoCD sync on AI recommendation | 🗺️ Planned |

---

## Contributing

```bash
git clone https://github.com/<your-username>/sentinel-ai-platform.git
git checkout -b feat/your-feature
```

Before submitting a PR:
- `pytest tests/ --cov=app --cov-fail-under=70` must pass
- `make deploy-all && make status` — all 3 envs healthy
- New endpoint = new tes
- New K8s manifest = must pass OPA admission policies
- New AI feature = test with Ollama running locally before pushing

---

<div align="center">

**Prakhar Srivastava** — DevOps Engineer

[LinkedIn](https://www.linkedin.com/in/heyyprakhar1/) · [Portfolio](https://prakharsrivastava-devops.netlify.app) · [Hashnode](https://hashnode.com/@heyyprakhar01)

</div>
