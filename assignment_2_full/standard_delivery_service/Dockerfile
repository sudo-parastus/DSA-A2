FROM ballerina/ballerina:latest

WORKDIR /app

COPY . .

RUN ballerina build standard_delivery_service

CMD ["bal", "run", "standard_delivery_service.bal"]