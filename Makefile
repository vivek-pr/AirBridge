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
        docker run --rm airbridge-edge-worker:3.0.4 --help

minikube-up: build-control-plane
        minikube start -p $(MINIKUBE_PROFILE)
        minikube image load -p $(MINIKUBE_PROFILE) airbridge-webserver:3.0.4
        minikube image load -p $(MINIKUBE_PROFILE) airbridge-scheduler:3.0.4
        minikube image load -p $(MINIKUBE_PROFILE) airbridge-triggerer:3.0.4
        helm upgrade --install $(HELM_RELEASE) infra/helm/airbridge -f $(HELM_VALUES)

minikube-down:
        -helm uninstall $(HELM_RELEASE)
        minikube delete -p $(MINIKUBE_PROFILE)
