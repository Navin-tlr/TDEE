# --- Build Stage ---
# Use an updated Go version that matches your project's requirement.
FROM golang:1.24-alpine AS builder

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
# Use a minimal, non-root base image for the final container.
FROM scratch

# Copy the built binary from the 'builder' stage.
COPY --from=builder /runner /runner

# Set the entrypoint for the container.
ENTRYPOINT ["/runner"]