# Stage 1: Build & Dependency Gathering
FROM python:3.11-slim AS builder

WORKDIR /app

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final Minimal Runtime Image
FROM python:3.11-alpine

WORKDIR /app

# Copy python virtual environment dependencies from builder
COPY --from=builder /opt/venv /opt/venv
# Copy application source code
COPY app.py .
COPY templates/ ./templates/

ENV PATH="/opt/venv/bin:$PATH"
EXPOSE 5000

CMD ["python", "app.py"]