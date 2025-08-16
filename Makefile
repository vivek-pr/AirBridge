.PHONY: build-webserver build-scheduler build-triggerer build-control-plane kind-up kind-down

KIND_CLUSTER_NAME ?= airbridge
HELM_RELEASE ?= airbridge-control-plane

build-webserver:
	docker build -t airbridge-webserver:3.0.4 -f control-plane/webserver/Dockerfile control-plane

build-scheduler:
	docker build -t airbridge-scheduler:3.0.4 -f control-plane/scheduler/Dockerfile control-plane

build-triggerer:
	docker build -t airbridge-triggerer:3.0.4 -f control-plane/triggerer/Dockerfile control-plane

build-control-plane: build-webserver build-scheduler build-triggerer

kind-up: build-control-plane
	kind create cluster --name $(KIND_CLUSTER_NAME)
	kind load docker-image airbridge-webserver:3.0.4 --name $(KIND_CLUSTER_NAME)
	kind load docker-image airbridge-scheduler:3.0.4 --name $(KIND_CLUSTER_NAME)
	kind load docker-image airbridge-triggerer:3.0.4 --name $(KIND_CLUSTER_NAME)
	helm upgrade --install $(HELM_RELEASE) infra/helm/airbridge -f infra/helm/airbridge/values-dev.yaml

kind-down:
	-helm uninstall $(HELM_RELEASE)
	kind delete cluster --name $(KIND_CLUSTER_NAME)
