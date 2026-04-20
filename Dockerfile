## ————————————————————————————————————————————————————————————————————————————
## Stage 1: Builder
## ————————————————————————————————————————————————————————————————————————————
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy and build source code
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o ./satcfdid ./cmd/satcfdid


## ————————————————————————————————————————————————————————————————————————————
## Stage 2: Runtime
## ————————————————————————————————————————————————————————————————————————————
FROM gcr.io/distroless/static-debian12:nonroot

# Copy binary from builder stage
COPY --from=builder /app/satcfdid /bin/satcfdid

# By default, the service runs with insecure h2c (HTTP/2 Cleartext).
ENV SAT_SERVICE_INSECURE_H2C=true

# To use TLS, set the following environment variables at runtime:
# ENV SAT_SERVICE_TLS_CERT=/path/to/cert.crt \
#     SAT_SERVICE_TLS_KEY=/path/to/key.key \
#     SAT_SERVICE_INSECURE_H2C=false

EXPOSE 8443

# Run server
ENTRYPOINT ["satcfdid"]

