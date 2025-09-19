# Use official nginx image as base
FROM nginx:1.25-alpine

# Set maintainer
LABEL maintainer="loveth.oballe@devopsengineer.com"
LABEL description="DevOps Portfolio Website"
LABEL version="1.0"

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy website files
COPY ./src /usr/share/nginx/html/

# Copy custom nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Create directory for certificates (for future SSL setup)
RUN mkdir -p /etc/nginx/ssl

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Create non-root user for security
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx-app -g nginx-app nginx-app

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose port 80 and 443
EXPOSE 80 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]