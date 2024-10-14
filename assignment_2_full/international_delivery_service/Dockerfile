FROM ballerina/ballerina:latest

WORKDIR /app

COPY . .

RUN ballerina build international_delivery_service

CMD ["bal", "run", "international_delivery_service.bal"]