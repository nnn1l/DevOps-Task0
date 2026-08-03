FROM python:3.11-alpine3.20

WORKDIR /app

RUN apk add --no-cache gcc musl-dev postgresql-dev

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x ./start.sh

EXPOSE 8000

ENTRYPOINT ["./start.sh"]