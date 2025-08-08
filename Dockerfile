FROM nginx:alpine

# Copy your HTML file
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80