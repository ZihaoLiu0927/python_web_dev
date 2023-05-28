FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8080
ENV ENVIRONMENT development
CMD ["python3", "www/app.py"]