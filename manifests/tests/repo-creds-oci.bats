#!/usr/bin/env bats

setup() {
  cd "$BATS_TEST_DIRNAME/.."
  RENDERED="$(helm template . )"
  export RENDERED
}

@test "renders argocd-repo-creds-oci ServiceAccount and SecretStore with vault config" {
  sa_name=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ServiceAccount" and .metadata.name == "argocd-repo-creds-oci-secret") | .metadata.name
  ' -)
  sa_namespace=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ServiceAccount" and .metadata.name == "argocd-repo-creds-oci-secret") | .metadata.namespace
  ' -)

  [ "$sa_name" = "argocd-repo-creds-oci-secret" ]
  [ "$sa_namespace" = "argocd" ]

  ss_namespace=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "SecretStore" and .metadata.name == "argocd-repo-creds-oci-openbao") | .metadata.namespace
  ' -)
  ss_server=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "SecretStore" and .metadata.name == "argocd-repo-creds-oci-openbao") | .spec.provider.vault.server
  ' -)
  ss_path=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "SecretStore" and .metadata.name == "argocd-repo-creds-oci-openbao") | .spec.provider.vault.path
  ' -)
  ss_version=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "SecretStore" and .metadata.name == "argocd-repo-creds-oci-openbao") | .spec.provider.vault.version
  ' -)
  ss_mount_path=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "SecretStore" and .metadata.name == "argocd-repo-creds-oci-openbao") | .spec.provider.vault.auth.kubernetes.mountPath
  ' -)
  ss_role=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "SecretStore" and .metadata.name == "argocd-repo-creds-oci-openbao") | .spec.provider.vault.auth.kubernetes.role
  ' -)
  ss_sa_ref=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "SecretStore" and .metadata.name == "argocd-repo-creds-oci-openbao") | .spec.provider.vault.auth.kubernetes.serviceAccountRef.name
  ' -)

  [ "$ss_namespace" = "argocd" ]
  [ "$ss_server" = "http://k8s-openbao.openbao.svc:8200" ]
  [ "$ss_path" = "kv" ]
  [ "$ss_version" = "v2" ]
  [ "$ss_mount_path" = "kubernetes" ]
  [ "$ss_role" = "argocd-repo-creds-oci" ]
  [ "$ss_sa_ref" = "argocd-repo-creds-oci-secret" ]
}

@test "renders argocd-repo-creds-oci ExternalSecret templating a repo-creds Secret from OpenBao" {
  es_namespace=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .metadata.namespace
  ' -)
  es_label=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.target.template.metadata.labels["argocd.argoproj.io/secret-type"]
  ' -)
  es_type=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.target.template.data.type
  ' -)
  es_enable_oci=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.target.template.data.enableOCI
  ' -)
  es_url=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.target.template.data.url
  ' -)
  es_username=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.target.template.data.username
  ' -)
  es_password=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.target.template.data.password
  ' -)
  es_remote_key=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.data[0].remoteRef.key
  ' -)
  es_store_name=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.secretStoreRef.name
  ' -)
  es_store_kind=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ExternalSecret" and .spec.data[0].remoteRef.property == "ZOT_CI_PASSWORD") | .spec.secretStoreRef.kind
  ' -)

  [ "$es_namespace" = "argocd" ]
  [ "$es_label" = "repo-creds" ]
  [ "$es_type" = "helm" ]
  [ "$es_enable_oci" = "true" ]
  [ "$es_url" = "registry.morrisons.site/charts" ]
  [ "$es_username" = "ci" ]
  [ -n "$es_password" ]
  [ "$es_remote_key" = "homelab/argocd" ]
  [ "$es_store_name" = "argocd-repo-creds-oci-openbao" ]
  [ "$es_store_kind" = "SecretStore" ]
}
