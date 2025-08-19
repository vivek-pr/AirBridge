.PHONY: build-webserver build-scheduler build-triggerer build-control-plane build-edge-worker run-edge-worker minikube-up minikube-down

MINIKUBE_PROFILE ?= airbridge
HELM_RELEASE ?= airbridge-control-plane

ENV ?= dev
HELM_VALUES ?= infra/helm/airbridge/values-$(ENV).yaml

build-webserver:
	docker build -t airbridge-webserver:3.0.4 -f control-plane/webserver/Dockerfile control-plane

build-scheduler:
	docker build -t airbridge-scheduler:3.0.4 -f control-plane/scheduler/Dockerfile control-plane

build-triggerer:
	docker build -t airbridge-triggerer:3.0.4 -f control-plane/triggerer/Dockerfile control-plane

build-control-plane: build-webserver build-scheduler build-triggerer

build-edge-worker:
	docker build -t airbridge-edge-worker:3.0.4 -f data-plane/worker/Dockerfile data-plane

run-edge-worker: build-edge-worker
	# Grab token from K8s secret (if running locally against your minikube control plane)
	EDGE_API_TOKEN=$$(kubectl get secret edge-api-token -o jsonpath='{.data.token}' | base64 -d) && \
	docker run --rm \
		-e CONTROL_PLANE_URL="http://localhost:8080" \
		-e EDGE_API_TOKEN="$$EDGE_API_TOKEN" \
		--name edge-worker airbridge-edge-worker:3.0.4

create-secrets:
	kubectl --context $(MINIKUBE_PROFILE) get secret jwt-secret >/dev/null 2>&1 || \
		kubectl --context $(MINIKUBE_PROFILE) create secret generic jwt-secret \
		--from-literal=token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlZGdlLXdvcmtlciIsImlhdCI6MTc1NTYzNTExNywibmJmIjoxNzU1NjM1MTEyLCJleHAiOjE3NTU2Mzg3MTcsImF1ZCI6InVybjphaXJmbG93LmFwYWNoZS5vcmc6dGFzayJ9.X4wUOu26SxckgkmmnytT_BYzYUernXmKw6Vy-cfkTak
	kubectl --context $(MINIKUBE_PROFILE) get secret edge-api-token >/dev/null 2>&1 || \
		kubectl --context $(MINIKUBE_PROFILE) create secret generic edge-api-token \
		--from-literal=token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJlZGdlLXdvcmtlciIsImlhdCI6MTc1NTYzNTExNywibmJmIjoxNzU1NjM1MTEyLCJleHAiOjE3NTU2Mzg3MTcsImF1ZCI6InVybjphaXJmbG93LmFwYWNoZS5vcmc6dGFzayJ9.X4wUOu26SxckgkmmnytT_BYzYUernXmKw6Vy-cfkTak

minikube-up: build-control-plane
	minikube start -p $(MINIKUBE_PROFILE)
	minikube image load -p $(MINIKUBE_PROFILE) airbridge-webserver:3.0.4
	minikube image load -p $(MINIKUBE_PROFILE) airbridge-scheduler:3.0.4
	minikube image load -p $(MINIKUBE_PROFILE) airbridge-triggerer:3.0.4
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

