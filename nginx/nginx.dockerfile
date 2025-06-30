# Use the official stable Nginx Alpine Linux image (small and secure)
FROM nginx:stable-alpine

# Copy your custom Nginx configuration file into the container
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Expose port 80 so the container can accept web traffic
EXPOSE 80

# Run Nginx in the foreground (keep container running)
CMD ["nginx", "-g", "daemon off;"]
