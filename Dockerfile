FROM nginx:alpine

# Install Docker CLI & engine in Alpine
USER root
RUN apk update && \
    apk add --no-cache docker-cli docker

# Copy your HTML file
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
