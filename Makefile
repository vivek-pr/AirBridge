.PHONY: build-webserver build-scheduler build-triggerer build-control-plane build-edge-worker kind-up kind-down

KIND_CLUSTER_NAME ?= airbridge
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

kind-up: build-control-plane
	kind create cluster --name $(KIND_CLUSTER_NAME)
	kind load docker-image airbridge-webserver:3.0.4 --name $(KIND_CLUSTER_NAME)
	kind load docker-image airbridge-scheduler:3.0.4 --name $(KIND_CLUSTER_NAME)
	kind load docker-image airbridge-triggerer:3.0.4 --name $(KIND_CLUSTER_NAME)
	helm upgrade --install $(HELM_RELEASE) infra/helm/airbridge -f $(HELM_VALUES)

kind-down:
	-helm uninstall $(HELM_RELEASE)
	kind delete cluster --name $(KIND_CLUSTER_NAME)
