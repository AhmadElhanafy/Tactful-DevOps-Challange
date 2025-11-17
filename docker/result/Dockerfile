# ===========================
# 1. BUILDER STAGE
# ===========================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy the application source
COPY . .


# ===========================
# 2. DISTROLESS RUNTIME STAGE
# ===========================
FROM gcr.io/distroless/nodejs20-debian12

WORKDIR /app

COPY --from=builder /app /app

EXPOSE 4000

# No healthcheck here — must be added in Kubernetes

CMD ["/app/server.js"]
