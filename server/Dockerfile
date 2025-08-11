# --- Build Stage ---
# Use an updated Go version that matches your project's requirement.
FROM golang:1.24-alpine AS builder

# Alpine Linux is a distribution that requires this for Go to work correctly
RUN apk add --no-cache git gcc libc-dev

WORKDIR /app

# Copy the Go module files and download dependencies.
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code.
# The path here should be relative to the WORKDIR, so we copy the project source
# into the current directory.
COPY ./cmd ./cmd
COPY ./internal ./internal

# Build the application.
RUN CGO_ENABLED=0 go build -o /runner ./cmd/runner

# --- Final Stage ---
# Use a minimal base image that INCLUDES SSL certificates. Alpine is a great choice.
FROM alpine:latest

# Import the certificate authorities from the build stage.
RUN apk --no-cache add ca-certificates

# Copy the built binary from the 'builder' stage.
COPY --from=builder /runner /runner

# Set the entrypoint for the container.
ENTRYPOINT ["/runner"]