# Use newer, safer base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies + clean cache
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip tools securely
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy only requirements first (better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

# Create non-root user (security best practice)
RUN useradd -m appuser
USER appuser

# Expose port
EXPOSE 5050

# Run app
CMD ["python", "app.py"]