FROM redis:7-alpine

# Install bash and dos2unix
RUN apk add --no-cache bash dos2unix

# Copy the healthcheck script into the image
COPY redis.sh /usr/local/bin/redis-health.sh

# Make it executable inside the image
RUN dos2unix /usr/local/bin/redis-health.sh \
    && chmod +x /usr/local/bin/redis-health.sh