start:
	docker run --rm -it --name qt qt
restart:
	docker rm -f qt
	docker run --rm -it --name qt qt
build:
	docker build -t qt .
.PHONY: start restart build
