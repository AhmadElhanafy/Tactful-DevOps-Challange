FROM postgres:15-alpine

# Install bash and dos2unix
RUN apk add --no-cache bash dos2unix

# Copy script and fix line endings
COPY postgres.sh /usr/local/bin/postgres-health.sh
RUN dos2unix /usr/local/bin/postgres-health.sh \
    && chmod +x /usr/local/bin/postgres-health.sh