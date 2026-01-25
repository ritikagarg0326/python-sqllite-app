FROM python:3.10-slim

# Set working directory inside container
WORKDIR /app


# Install dependencies
RUN pip install flask

# Copy all files into the container
COPY . .

# Expose Flask default port
EXPOSE 5050

# Run the Flask app
CMD ["python", "app.py"]