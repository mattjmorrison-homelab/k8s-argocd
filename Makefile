.PHONY: install upgrade check

install:
	kubectl apply -f manifests/namespace.yaml
	kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl wait --for=condition=available --timeout=120s deployment/argocd-server -n argocd
	kubectl apply -f manifests/root-app.yaml
	kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

upgrade:
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.14.0/manifests/install.yaml

check:
	nix shell nixpkgs#kubernetes-helm nixpkgs#bats nixpkgs#yq-go -c bats manifests/tests
