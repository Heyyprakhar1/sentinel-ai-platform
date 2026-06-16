import React from 'react'

export default function NamespaceCard({ namespace, selected, onClick }) {

  const statusColors = {
    healthy: 'var(--accent-green)',
    warning: 'var(--accent-amber)',
    critical: 'var(--accent-red)',
  }

  const color =
    statusColors[namespace.status] ||
    'var(--accent-blue)'

  return (
    <div
      onClick={() => onClick(namespace)}
      style={{
        cursor: 'pointer',
        background: 'var(--bg-surface)',
        border: selected
          ? `2px solid ${color}`
          : '1px solid var(--border)',
        borderRadius: 'var(--radius-lg)',
        padding: 16,
        transition: 'all 0.2s ease',
      }}
    >
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          marginBottom: 10,
        }}
      >
        <span
          style={{
            fontFamily: 'var(--font-mono)',
            fontSize: 12,
            fontWeight: 600,
          }}
        >
          {namespace.name}
        </span>

        <span
          style={{
            color,
            fontSize: 11,
            fontWeight: 600,
            textTransform: 'uppercase',
          }}
        >
          {namespace.status}
        </span>
      </div>

      <div
        style={{
          fontSize: 28,
          fontWeight: 700,
          color,
          marginBottom: 10,
        }}
      >
        {namespace.health_score}%
      </div>

      <div
        style={{
          fontSize: 11,
          color: 'var(--text-muted)',
          fontFamily: 'var(--font-mono)',
        }}
      >
        Pods: {namespace.pods}
      </div>

      <div
        style={{
          fontSize: 11,
          color: 'var(--text-muted)',
          fontFamily: 'var(--font-mono)',
        }}
      >
        Issues: {namespace.issues}
      </div>
    </div>
  )
}
