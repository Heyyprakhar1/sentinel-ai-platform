const BASE = import.meta.env.VITE_API_URL || '/api'
const PROM = import.meta.env.VITE_PROM_URL || '/prometheus'  // localhost:9090 → /prometheus

async function get(path) {
  const res = await fetch(`${BASE}${path}`)
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
  return res.json()
}

async function promQuery(query) {
  const params = new URLSearchParams({ query })
  const res = await fetch(`${PROM}/api/v1/query?${params}`)
  if (!res.ok) throw new Error(`Prometheus ${res.status}`)
  const data = await res.json()
  return data.data.result
}

export const api = {
  health:         () => get('/health'),
  status:         () => get('/status'),
  metrics:        () => get('/metrics'),
  alerts:         () => get('/alerts'),
  recommendation: () => get('/recommendation'),
  clusterOverview: () => get('/cluster/overview'),

  namespaceDetails: (name) =>
    get(`/namespace/${name}`),
  
  namespaceRCA: (name) =>
    get(`/namespace/${name}/rca`),

}

export const prom = {
  podCPU: () => promQuery('sum(rate(container_cpu_usage_seconds_total{namespace="sentinelai-dev"}[5m]))by(pod)'),
  podMemory: () => promQuery('sum(container_memory_working_set_bytes{namespace="sentinelai-dev"})by(pod)'),
  nodeIdleCPU: () => promQuery('avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))*100'),
  podCount: () => promQuery('count(kube_pod_status_ready{namespace="sentinelai-dev",condition="true"})'),
}

export function parseMetricsFromRec(rec) {
  if (!rec?.recommendation) return { cpu: null, memory: null }
  const cpu    = rec.recommendation.match(/CPU at ([\d.]+)%/i)
  const memory = rec.recommendation.match(/memory at ([\d.]+)%/i)
  return {
    cpu:    cpu    ? parseFloat(cpu[1])    : null,
    memory: memory ? parseFloat(memory[1]) : null,
  }
}
