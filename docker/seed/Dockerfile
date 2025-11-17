FROM alpine:3.20

# Install Python + ApacheBench
RUN apk add --no-cache python3 py3-pip apache2-utils

WORKDIR /seed

# Copy Python script and shell script
COPY make-data.py .
COPY generate-votes.sh .

# Make shell script executable
RUN chmod +x generate-votes.sh

# Run Python script first, then seed script only if Python succeeded
ENTRYPOINT ["sh", "-c", "python3 /seed/make-data.py && sh /seed/generate-votes.sh"]
