# golang:1.17-alpine base image
FROM golang:1.17-alpine

WORKDIR /app

COPY app/web.go /app
COPY app/frontend /app/frontend
COPY app/data-storage /app/data-storage

RUN go mod init challenge

# tidy
RUN go mod tidy

# compile application
RUN go build -o /app/data-import-app

# god mode
RUN chmod 777 /app/data-import-app

EXPOSE 80

CMD [ "/app/data-import-app" ]