# ── Stage 1: Build ────────────────────────────────────────────
FROM golang:1.22-alpine AS builder
WORKDIR /src

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app ./cmd/...

# ── Stage 2: Runtime (minimal scratch image) ──────────────────
FROM scratch AS runtime

ENV PORT=<<PORT>>

# Copy CA certs for HTTPS calls
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /app /app

EXPOSE <<PORT>>
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["/app", "-healthcheck"]

ENTRYPOINT ["/app"]
