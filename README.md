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

## Tests

```
make check
```

Runs the bats suite in `manifests/tests` against `helm template` output — no cluster required.

## CI

Pull requests run `mattjmorrison-homelab/actions-helm` (helm lint, `helm template`, and a server-side dry-run) via `.github/workflows/check.yml`.

## What comes next

- `homelab-apps` — an "App of Apps" repo that ArgoCD watches; contains an ArgoCD `Application` manifest for each tool to deploy
- `homelab-<tool>` — one repo per tool; each has its own manifests and lifecycle

To add a new tool: create a `homelab-<tool>` repo, then add an `Application` manifest pointing at it in `homelab-apps`. ArgoCD picks it up automatically.

## OCI Helm Registry Credentials (repo-creds)

ArgoCD is configured to authenticate to `registry.morrisons.site/charts` (an OCI Helm registry) at sync time via ExternalSecret and OpenBao:

- **ServiceAccount**: `argocd-repo-creds-oci-secret` — identity for OpenBao kubernetes auth
- **SecretStore**: `argocd-repo-creds-oci-openbao` — vault provider at `http://k8s-openbao.openbao.svc:8200`, kubernetes auth role `argocd-repo-creds-oci`
- **ExternalSecret**: `argocd-repo-creds-oci` — templates a Secret labeled `argocd.argoproj.io/secret-type: repo-creds` with helm type, OCI enabled, and credentials from OpenBao path `homelab/argocd` property `ZOT_CI_PASSWORD`

**Setup requirement**: the OpenBao secret `homelab/argocd:ZOT_CI_PASSWORD` must be created manually; it is not part of this repo. Other homelab-* repos follow the same pattern for the same `ci` registry user (e.g. homelab-woodpecker's `zot-pull` reads `homelab/woodpecker:ZOT_CI_PASSWORD`) — each repo keeps its own copy of the password under its own OpenBao path, not a single shared secret.

**Unverified**: this repo only covers rendering the ServiceAccount/SecretStore/ExternalSecret via `helm template` + `make check`; actual OCI chart resolution by `argocd-repo-server` at sync time has not been verified against the live cluster.
