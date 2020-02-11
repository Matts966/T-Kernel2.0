run: build
	docker run --rm -it qt
run-net-host: build
	docker run --rm -it --net=host qt
run-with-vnc: build
	docker run --rm -it -p 5900:5900 qt true
start:
	docker run --rm -it qt
build:
	DOCKER_BUILDKIT=1 docker build -t qt .
build-without-cache:
	DOCKER_BUILDKIT=1 docker build -t qt --no-cache .
install-gc:
	cp gc/src/* src
.PHONY: start restart build
