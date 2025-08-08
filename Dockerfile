FROM jenkins/jenkins:lts

USER root
# Install Nginx and Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io nginx && \
    rm -rf /var/lib/apt/lists/*

# Copy your HTML file into Nginx webroot
COPY index.html /var/www/html/index.html

# Configure Nginx to run on port 80
RUN echo 'daemon off;' >> /etc/nginx/nginx.conf

# Expose Jenkins (8080), Nginx (80), and Jenkins agent port (50000)
EXPOSE 8080 50000 80

# Start both Jenkins and Nginx together
CMD service nginx start && exec /usr/bin/tini -- /usr/local/bin/jenkins.sh
