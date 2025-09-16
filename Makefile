.PHONY: build-webserver build-scheduler build-triggerer build-control-plane build-edge-worker run-edge-worker minikube-up minikube-down

MINIKUBE_PROFILE ?= airbridge
HELM_RELEASE ?= airbridge-control-plane

ENV ?= dev
HELM_VALUES ?= infra/helm/airbridge/values-$(ENV).yaml

build-webserver:
	docker build -t airbridge-webserver:3.0.6 -f control-plane/webserver/Dockerfile control-plane
	# Backward-compat tag expected by some scripts/tests
	-docker tag airbridge-webserver:3.0.6 airbridge-webserver:3.0.4

build-scheduler:
	docker build -t airbridge-scheduler:3.0.6 -f control-plane/scheduler/Dockerfile control-plane
	# Backward-compat tag expected by some scripts/tests
	-docker tag airbridge-scheduler:3.0.6 airbridge-scheduler:3.0.4

build-triggerer:
	docker build -t airbridge-triggerer:3.0.6 -f control-plane/triggerer/Dockerfile control-plane
	# Backward-compat tag expected by some scripts/tests
	-docker tag airbridge-triggerer:3.0.6 airbridge-triggerer:3.0.4

build-control-plane: build-webserver build-scheduler build-triggerer

build-edge-worker:
	docker build -t airbridge-edge-worker:3.0.6 -f data-plane/worker/Dockerfile data-plane
	# Backward-compat tag expected by some scripts/tests
	-docker tag airbridge-edge-worker:3.0.6 airbridge-edge-worker:3.0.4

run-edge-worker: build-edge-worker
	# Grab token from K8s secret (if running locally against your minikube control plane)
	EDGE_API_TOKEN=$$(kubectl get secret edge-api-token -o jsonpath='{.data.token}' | base64 -d) && \
	docker run --rm \
		-e CONTROL_PLANE_URL="http://localhost:8080" \
		-e EDGE_API_TOKEN="$$EDGE_API_TOKEN" \
		--name edge-worker airbridge-edge-worker:3.0.6

create-secrets:
	kubectl --context $(MINIKUBE_PROFILE) get secret jwt-secret >/dev/null 2>&1 || \
		kubectl --context $(MINIKUBE_PROFILE) create secret generic jwt-secret \
		--from-literal=token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlZGdlLXdvcmtlciIsImlhdCI6MTc1NTYzNTExNywibmJmIjoxNzU1NjM1MTEyLCJleHAiOjE3NTU2Mzg3MTcsImF1ZCI6InVybjphaXJmbG93LmFwYWNoZS5vcmc6dGFzayJ9.X4wUOu26SxckgkmmnytT_BYzYUernXmKw6Vy-cfkTak
	kubectl --context $(MINIKUBE_PROFILE) get secret edge-api-token >/dev/null 2>&1 || \
		kubectl --context $(MINIKUBE_PROFILE) create secret generic edge-api-token \
		--from-literal=token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlZGdlLXdvcmtlciIsImlhdCI6MTc1NTYzNTExNywibmJmIjoxNzU1NjM1MTEyLCJleHAiOjE3NTU2Mzg3MTcsImF1ZCI6InVybjphaXJmbG93LmFwYWNoZS5vcmc6dGFzayJ9.X4wUOu26SxckgkmmnytT_BYzYUernXmKw6Vy-cfkTak
	# SimpleAuth passwords secret (contains JSON: {"admin":"<password>"})
	kubectl --context $(MINIKUBE_PROFILE) get secret airflow-simple-auth >/dev/null 2>&1 || \
		( \
		  PASS="$${AIRFLOW_ADMIN_PASSWORD:-$$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)}"; \
		  kubectl --context $(MINIKUBE_PROFILE) create secret generic airflow-simple-auth \
		    --from-literal=simple_auth_manager_passwords.json="{\"admin\":\"$${PASS}\"}"; \
		  echo "Created secret airflow-simple-auth (admin password: $${PASS})"; \
		)

minikube-up: build-control-plane
		minikube start -p $(MINIKUBE_PROFILE) --wait=apiserver,system_pods,default_sa --wait-timeout=8m
		$(MAKE) minikube-repair-kubeconfig
	minikube image load -p $(MINIKUBE_PROFILE) airbridge-webserver:3.0.6
	minikube image load -p $(MINIKUBE_PROFILE) airbridge-scheduler:3.0.6
	minikube image load -p $(MINIKUBE_PROFILE) airbridge-triggerer:3.0.6
	minikube image load -p $(MINIKUBE_PROFILE) postgres:15
	helm upgrade --install $(HELM_RELEASE) infra/helm/airbridge -f $(HELM_VALUES)

	# ensure secrets exist
	$(MAKE) create-secrets

	# wait for pods
	kubectl --context $(MINIKUBE_PROFILE) wait --for=condition=Ready pod -l app=$(HELM_RELEASE)-postgres --timeout=180s
	kubectl --context $(MINIKUBE_PROFILE) wait --for=condition=Ready pod -l app=$(HELM_RELEASE)-webserver --timeout=180s
	kubectl --context $(MINIKUBE_PROFILE) wait --for=condition=Ready pod -l app=$(HELM_RELEASE)-scheduler --timeout=180s

	# copy DAGs to webserver
	WEB_POD=$$(kubectl --context $(MINIKUBE_PROFILE) get pods -l app=$(HELM_RELEASE)-webserver -o jsonpath='{.items[0].metadata.name}') && \
	kubectl --context $(MINIKUBE_PROFILE) cp control-plane/dags/. $$WEB_POD:/opt/airflow/dags

	# copy DAGs to scheduler and reserialize
	SC_POD=$$(kubectl --context $(MINIKUBE_PROFILE) get pods -l app=$(HELM_RELEASE)-scheduler -o jsonpath='{.items[0].metadata.name}') && \
	kubectl --context $(MINIKUBE_PROFILE) cp control-plane/dags/. $$SC_POD:/opt/airflow/dags && \
	kubectl --context $(MINIKUBE_PROFILE) exec $$SC_POD -- bash -lc 'airflow db check && airflow dags reserialize'

	
	

minikube-down:
		-helm uninstall $(HELM_RELEASE)
		minikube delete -p $(MINIKUBE_PROFILE)

# Workaround for addon failures when kubeconfig inside node points to IPv6 localhost
minikube-repair-kubeconfig:
		@set -e; \
		minikube ssh -p $(MINIKUBE_PROFILE) -- "sudo sed -i 's#https://localhost:8443#https://127.0.0.1:8443#' /var/lib/minikube/kubeconfig || true"; \
		minikube ssh -p $(MINIKUBE_PROFILE) -- "grep server: /var/lib/minikube/kubeconfig || true"; \
		kubectl --context $(MINIKUBE_PROFILE) wait --for=condition=Ready node --all --timeout=180s || true; \
		minikube addons enable default-storageclass -p $(MINIKUBE_PROFILE) || true; \
		minikube addons enable storage-provisioner -p $(MINIKUBE_PROFILE) || true
