# EKS Cluster Monitoring

Production-grade Prometheus alerting rules and Grafana dashboard configuration for an EKS cluster.

## Prometheus Alert Rules

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: eks-cluster-alerts
  namespace: monitoring
spec:
  groups:
    - name: eks-cluster
      rules:
        - alert: HighNodeCPU
          expr: 100 - (rate(node_cpu_seconds_total{mode="idle"}[5m]) * 100) > 80
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High CPU usage on {{ $labels.instance }}"
        - alert: PodCrashLoop
          expr: rate(kube_pod_container_status_restarts_total[1m]) > 0
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "Pod {{ $labels.pod }} is restarting repeatedly"
        - alert: KubeAPIHighLatency
          expr: histogram_quantile(0.99, sum(rate(kube_api_server_request_duration_seconds_bucket[5m])) by (le)) > 1
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Kubernetes API latency above 1s"
```

## What this demonstrates

- Real production alerting rules: CPU saturation, Pod crash loops, API latency
- PrometheusRule custom resource for GitOps delivery
- Alert severity classification (warning vs critical) with actionable summaries