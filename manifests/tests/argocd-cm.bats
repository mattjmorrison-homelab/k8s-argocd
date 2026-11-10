#!/usr/bin/env bats

setup() {
  cd "$BATS_TEST_DIRNAME/.."
  RENDERED="$(helm template . )"
  export RENDERED
}

@test "renders argocd-cm with a 3m reconciliation timeout" {
  value=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "ConfigMap" and .metadata.name == "argocd-cm") | .data["timeout.reconciliation"]
  ' -)
  [ "$value" = "3m" ]
}
