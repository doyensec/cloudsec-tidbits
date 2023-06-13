# golang:1.17-alpine base image
FROM golang:1.17-alpine

WORKDIR /app

COPY app/web.go /app
COPY app/frontend /app/frontend

RUN go mod init pills

# tidy
RUN go mod tidy

# compile application
RUN go build -o /app/batch-app

# god mode
RUN chmod 777 /app/batch-app

EXPOSE 80

CMD [ "/app/batch-app" ]