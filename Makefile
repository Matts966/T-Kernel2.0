run: build
	docker run --rm -it qt
run-net-host: build
	docker run --rm -it --net=host qt
run-with-vnc: build
	docker run --rm -it -p 5900:5900 qt true
start:
	docker run --rm -it qt
build:
	docker build -t qt .
.PHONY: start restart build
