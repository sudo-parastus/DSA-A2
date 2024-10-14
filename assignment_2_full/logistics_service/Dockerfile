FROM ballerina/ballerina:latest

WORKDIR /app

COPY . .

RUN ballerina build logistics_service

EXPOSE 8080

CMD ["bal", "run", "logistics_service.bal"]