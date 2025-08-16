.PHONY: build-webserver build-scheduler build-triggerer build-control-plane

build-webserver:
	docker build -t airbridge-webserver:3.0.4 -f control-plane/webserver/Dockerfile control-plane

build-scheduler:
	docker build -t airbridge-scheduler:3.0.4 -f control-plane/scheduler/Dockerfile control-plane

build-triggerer:
	docker build -t airbridge-triggerer:3.0.4 -f control-plane/triggerer/Dockerfile control-plane

build-control-plane: build-webserver build-scheduler build-triggerer
