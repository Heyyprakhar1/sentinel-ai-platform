import React, { useCallback, useState, useEffect } from 'react'
import { Server } from 'lucide-react'

import { api } from '../lib/api'
import { usePolling } from '../hooks/usePolling'

import NamespaceCard from './NamespaceCard'
import NamespaceDetails from './NamespaceDetails'

export default function K8sPanel() {

  const clusterFetch = useCallback(
    api.clusterOverview,
    []
  )

  const {
    data: clusterData
  } = usePolling(
    clusterFetch,
    15000
  )

  const [selectedNamespace, setSelectedNamespace] =
    useState(null)

  useEffect(() => {

    if (
      clusterData?.namespaces?.length &&
      !selectedNamespace
    ) {
      setSelectedNamespace(
        clusterData.namespaces[0]
      )
    }

  }, [clusterData])

  if (!clusterData) {
    return (
      <div
        style={{
          padding: 20,
          textAlign: 'center',
        }}
      >
        Loading cluster data...
      </div>
    )
  }

  return (
    <div
      style={{
        background: 'var(--bg-surface)',
        border: '1px solid var(--border)',
        borderTop: '3px solid var(--accent-blue)',
        borderRadius: 'var(--radius-lg)',
        padding: '20px',
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 8,
          marginBottom: 20,
        }}
      >
        <Server
          size={15}
          color="var(--accent-blue)"
        />

        <span
          style={{
            fontFamily: 'var(--font-mono)',
            fontSize: 12,
            textTransform: 'uppercase',
            color: 'var(--text-muted)',
          }}
        >
          Kubernetes AI Operations Center
        </span>
      </div>

      <div
        style={{
          display: 'flex',
          gap: 20,
          marginBottom: 20,
        }}
      >
        <div>
          <div
            style={{
              fontSize: 11,
              color: 'var(--text-muted)',
            }}
          >
            Cluster Score
          </div>

          <div
            style={{
              fontSize: 32,
              fontWeight: 700,
            }}
          >
            {clusterData.cluster_score}%
          </div>
        </div>

        <div>
          <div
            style={{
              fontSize: 11,
              color: 'var(--text-muted)',
            }}
          >
            Namespaces
          </div>

          <div
            style={{
              fontSize: 32,
              fontWeight: 700,
            }}
          >
            {clusterData.namespace_count}
          </div>
        </div>
      </div>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns:
            'repeat(auto-fill,minmax(220px,1fr))',
          gap: 14,
          marginBottom: 20,
        }}
      >
        {clusterData.namespaces.map(ns => (

          <NamespaceCard
            key={ns.name}
            namespace={ns}
            selected={
              selectedNamespace?.name === ns.name
            }
            onClick={setSelectedNamespace}
          />

        ))}
      </div>

      <NamespaceDetails
        namespace={selectedNamespace}
      />

    </div>
  )
}
