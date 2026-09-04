# homelab-argocd

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

## CI

Pull requests run `mattjmorrison-homelab/actions-helm` (helm lint, `helm template`, and a server-side dry-run) via `.github/workflows/check.yml`.

## What comes next

- `homelab-apps` — an "App of Apps" repo that ArgoCD watches; contains an ArgoCD `Application` manifest for each tool to deploy
- `homelab-<tool>` — one repo per tool; each has its own manifests and lifecycle

To add a new tool: create a `homelab-<tool>` repo, then add an `Application` manifest pointing at it in `homelab-apps`. ArgoCD picks it up automatically.
