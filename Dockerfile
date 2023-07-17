FROM debian:11

RUN apt-get update \
 && apt-get install --assume-yes --no-install-recommends --quiet \
    ca-certificates cmake git pkg-config make build-essential libssl-dev
RUN apt-get clean all

RUN git clone https://github.com/quicr/quicrq/
WORKDIR /quicrq

RUN cmake .
RUN make


