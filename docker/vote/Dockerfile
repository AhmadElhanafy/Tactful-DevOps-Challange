# ===========================
# 1. BUILDER STAGE
# ===========================
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies only for this stage (if needed for wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirement file
COPY requirements.txt .

# Install dependencies into a local folder (not system-wide)
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt


# ===========================
# 2. FINAL RUNTIME STAGE
# ===========================
FROM python:3.12-slim

# Create non-root user
RUN useradd -m voter

WORKDIR /app

# Copy dependencies from builder stage
COPY --from=builder /install /usr/local

# Copy source code
COPY . .

# Switch to non-root user
USER voter

# Expose Flask/Gunicorn port
EXPOSE 8080

# Health check (Docker)
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1

# Production WSGI server
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
