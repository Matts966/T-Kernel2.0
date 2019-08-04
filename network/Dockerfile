FROM docker
RUN apk add make bash
ADD . /tkernel/
COPY network/network-entrypoint.sh /tkernel
WORKDIR /tkernel
ENTRYPOINT [ "./network-entrypoint.sh" ]
