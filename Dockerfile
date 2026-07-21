FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    git \
    openssh-client \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY backup.sh /app/backup.sh
RUN chmod +x /app/backup.sh

CMD ["/app/backup.sh"]
