# syntax=docker/dockerfile:1

FROM golang:1.23 AS BUILD
WORKDIR /app
ARG BUILD_VERSION=dev

# Download Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code. Note the slash at the end, as explained in
# https://docs.docker.com/reference/dockerfile/#copy
COPY *.go ./

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-X 'main.Version=${BUILD_VERSION}'" -o /turbostat-exporter

FROM debian:sid-slim

RUN <<EOF
    apt update
    apt install -y linux-cpupower 
    rm -rf /var/lib/apt/lists/*
EOF

COPY --from=BUILD /turbostat-exporter /usr/bin/turbostat-exporter

