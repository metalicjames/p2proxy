# build stage
FROM golang:alpine as build-env
RUN apk --no-cache add bash build-base git mercurial gcc musl-dev pkgconfig libsodium-dev
ENV CGO_LDFLAGS="$CGO_LDFLAGS -lstdc++ -lm -lsodium"
ENV CGO_ENABLED=1
ENV GOOS=linux
RUN go get github.com/btcsuite/btcd/blockchain/...
RUN go get github.com/btcsuite/btcd/chaincfg/...
RUN go get github.com/btcsuite/btcd/txscript/...
RUN go get github.com/btcsuite/btcd/wire/...
RUN go get github.com/btcsuite/btcutil/...
RUN go get github.com/gertjaap/verthash-go/...
RUN go get github.com/mattn/go-sqlite3/...
RUN go get github.com/mit-dci/lit/bech32
RUN mkdir -p /go/src/github.com/gertjaap/p2proxy
ADD . /go/src/github.com/gertjaap/p2proxy
WORKDIR /go/src/github.com/gertjaap/p2proxy
RUN go get ./...
RUN go build -o p2proxy

# final stage
FROM alpine
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=build-env /go/src/github.com/gertjaap/p2proxy/p2proxy /app/
COPY --from=build-env /go/src/github.com/gertjaap/p2proxy/networks /app/networks
ENTRYPOINT ./p2proxy
