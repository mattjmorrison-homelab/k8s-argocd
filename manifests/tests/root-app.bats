#!/usr/bin/env bats

setup() {
  cd "$BATS_TEST_DIRNAME/.."
  RENDERED="$(helm template . )"
  export RENDERED
}

@test "renders root Application with repoURL pointing at k8s-apps" {
  value=$(echo "$RENDERED" | yq eval-all '
    select(.kind == "Application" and .metadata.name == "root") | .spec.source.repoURL
  ' -)
  [ "$value" = "https://github.com/mattjmorrison-homelab/k8s-apps" ]
}
