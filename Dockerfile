FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# Create user
RUN useradd -m appuser

# 🔥 FIX: set permissions BEFORE switching user
RUN chown -R appuser:appuser /app && \
    chmod -R 775 /app

# Switch user
USER appuser

EXPOSE 5050

CMD ["python", "app.py"]