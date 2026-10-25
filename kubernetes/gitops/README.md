# GitOps with ArgoCD

Declarative continuous delivery for Kubernetes. The cluster state is defined in Git and synced automatically by ArgoCD — no `kubectl apply` by hand, no drift.

## Structure

```
kubernetes/gitops/
├── argocd/
│   ├── install-argocd.sh          # Bootstrap ArgoCD into the cluster
│   ├── application.yaml           # ArgoCD Application watching this repo
│   └── project.yaml               # AppProject with restrictions
└── apps/
    └── demo-app/
        ├── namespace.yaml
        ├── deployment.yaml        # 3 replicas + probes + resource limits
        ├── service.yaml
        ├── ingress.yaml           # NGINX Ingress with TLS
        └── hpa.yaml               # Horizontal Pod Autoscaler
```

## Bootstrap ArgoCD

```bash
./argocd/install-argocd.sh
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application.yaml
```

ArgoCD then syncs `apps/` into the cluster every 3 minutes and reverts any manual change — the Git repo is the single source of truth.

## What this demonstrates

- ArgoCD Application + AppProject manifests with sync policies (self-heal, prune, automated sync)
- A deployment-ready app bundle: Deployment with liveness/readiness probes, Service, NGINX Ingress, HPA
- Declarative rollback: any bad change is fixed by reverting a commit, not by touching the cluster
