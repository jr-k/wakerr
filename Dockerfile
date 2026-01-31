FROM alpine:latest

# Install bash, curl & jq
RUN apk add --no-cache bash curl jq

# Copy scripts
WORKDIR /app
COPY entrypoint.sh search.sh .

# Make scripts executable
RUN chmod +x entrypoint.sh search.sh

# Default interval (can be overridden)
ENV INTERVAL_HOURS=24

ENTRYPOINT ["./entrypoint.sh"]
