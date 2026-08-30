# k8s-argocd

[Homelab Docs](https://github.com/mattjmorrison/homelab/blob/main/docs/INDEX.md)

---

Bootstrap ArgoCD into the k3s cluster. ArgoCD becomes the single tool used to deploy everything else to the cluster going forward.

## Install

```
make install
```

## Upgrade ArgoCD

```
make upgrade
```

ArgoCD handles its own rolling update.

## What comes next

- `k8s-apps` — an "App of Apps" repo that ArgoCD watches; contains an ArgoCD `Application` manifest for each tool to deploy
- `k8s-<tool>` — one repo per tool; each has its own manifests and lifecycle

To add a new tool: create a `k8s-<tool>` repo, then add an `Application` manifest pointing at it in `k8s-apps`. ArgoCD picks it up automatically.
