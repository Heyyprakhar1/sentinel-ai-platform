import React, {
  useEffect,
  useState
} from 'react'

import { api } from '../lib/api'

export default function NamespaceDetails({
  namespace
}) {

  const [rca, setRca] =
    useState(null)

  const [loadingRca, setLoadingRca] =
    useState(false)

  useEffect(() => {

    if (
      !namespace ||
      namespace.issues === 0
    ) {
      setRca(null)
      return
    }

    setLoadingRca(true)
    setRca(null)

    api
      .namespaceRCA(namespace.name)
      .then(data => {

        console.log(
          'RCA DATA:',
          data
        )

        setRca(data)

      })
      .catch(error => {

        console.error(
          'RCA ERROR:',
          error
        )

      })
      .finally(() => {

        setLoadingRca(false)

      })

  }, [namespace])

  if (!namespace) {

    return (
      <div
        style={{
          padding: 20,
          textAlign: 'center',
          color: 'var(--text-muted)',
        }}
      >
        Select a namespace
      </div>
    )
  }

  return (
    <div
      style={{
        background: 'var(--bg-surface)',
        border: '1px solid var(--border)',
        borderRadius: 'var(--radius-lg)',
        padding: 20,
      }}
    >

      <h3>{namespace.name}</h3>

      <p>
        Health Score:
        {' '}
        {namespace.health_score}%
      </p>

      <p>
        Pods:
        {' '}
        {namespace.pods}
      </p>

      <p>
        Deployments:
        {' '}
        {namespace.deployments}
      </p>

      <p>
        Services:
        {' '}
        {namespace.services}
      </p>

      <p>
        Status:
        {' '}
        {namespace.status}
      </p>

      <p>
        Issues:
        {' '}
        {namespace.issues}
      </p>

      <hr
        style={{
          margin: '20px 0',
          borderColor: 'var(--border)',
        }}
      />

      {
        namespace.issues === 0 && (
          <div
            style={{
              color: '#22c55e',
              fontWeight: 600
            }}
          >
            ✅ No active issues detected.
            RCA not required.
          </div>
        )
      }

      {
        namespace.issues > 0 && (
          <>
            <h4
              style={{
                marginBottom: 12,
                color: '#60a5fa'
              }}
            >
              AI RCA REPORT
            </h4>

            {
              loadingRca && (
                <div
                  style={{
                    color: '#f59e0b'
                  }}
                >
                  Generating RCA...
                </div>
              )
            }

            {
              rca &&
              rca.analysis && (

                <div
                  style={{
                    background:
                      'var(--bg-elevated)',
                    padding: 16,
                    borderRadius: 8,
                    border:
                      '1px solid var(--border)'
                  }}
                >

                  <div
                    style={{
                      marginBottom: 12
                    }}
                  >
                    <strong>
                      Namespace:
                    </strong>
                    {' '}
                    {rca.namespace}
                  </div>

                  <div
                    style={{
                      marginBottom: 12
                    }}
                  >
                    <strong>
                      Pod:
                    </strong>
                    {' '}
                    {rca.pod}
                  </div>

                  <div
                    style={{
                      marginBottom: 12
                    }}
                  >
                    <strong>
                      Root Cause:
                    </strong>
                    <br />
                    {
                      rca.analysis.root_cause
                    }
                  </div>

                  <div
                    style={{
                      marginBottom: 12
                    }}
                  >
                    <strong>
                      Severity:
                    </strong>
                    {' '}
                    {
                      rca.analysis.severity
                    }
                  </div>

                  <div
                    style={{
                      marginBottom: 12
                    }}
                  >
                    <strong>
                      Confidence:
                    </strong>
                    {' '}
                    {
                      rca.analysis.confidence
                    }
                  </div>

                  <div
                    style={{
                      marginBottom: 12
                    }}
                  >
                    <strong>
                      Recommended Fix:
                    </strong>

                    <div
                      style={{
                        marginTop: 6,
                        whiteSpace:
                          'pre-wrap'
                      }}
                    >
                      {
                        rca.analysis
                          .recommended_fix
                      }
                    </div>
                  </div>

                  {
                    rca.analysis
                      ?.evidence
                      ?.length > 0 && (

                      <div>

                        <strong>
                          Evidence:
                        </strong>

                        <ul
                          style={{
                            marginTop: 10
                          }}
                        >
                          {
                            rca.analysis
                              .evidence
                              .map(
                                (
                                  item,
                                  index
                                ) => (
                                  <li
                                    key={
                                      index
                                    }
                                    style={{
                                      marginBottom:
                                        8
                                    }}
                                  >
                                    <strong>
                                      {
                                        item.type
                                      }
                                    </strong>

                                    {' - '}

                                    {
                                      item.description
                                    }

                                  </li>
                                )
                              )
                          }
                        </ul>

                      </div>

                    )
                  }

                </div>

              )
            }

          </>
        )
      }

    </div>
  )
}
