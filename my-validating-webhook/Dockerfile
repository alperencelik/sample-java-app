# Use an official Golang base image
FROM golang:1.19-alpine AS build

# Set the working directory inside the container
WORKDIR /go/src/app

# Copy the Go source code into the container
COPY main.go go.mod go.sum /go/src/app/

# Build the Go application
RUN go build -o /go/bin/validate-webhook

# Use a minimal base image for the final container
FROM alpine:3.14

# Copy the built Go application from the previous stage
COPY --from=build /go/bin/validate-webhook /usr/local/bin/

# Copy the TLS certificates (tls.crt and tls.key) into the container
COPY cert.pem key.pem /

# Set the entry point for the container
ENTRYPOINT ["/usr/local/bin/validate-webhook"]

# Expose the webhook server port (optional)
EXPOSE 8080
