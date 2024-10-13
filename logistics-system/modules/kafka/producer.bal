import ballerina/kafka;
import logistics-system/modules/delivery as delivery;

public class RequestProducer {
    private kafka:Producer producer;

    public function init() {
        self.producer = new ({
            connectionTimeout: 10000,
            socketTimeout: 10000,
            bootstrapServers: "localhost:9092"
        });
    }

    public function sendRequest(delivery:DeliveryRequest request) {
        // Publish the request to a Kafka topic
        error? result = self.producer->send({
            topic: "delivery-requests",
            value: request
        });

        if (result is error) {
            log:printError("Failed to send request to Kafka: ", err = result);
        } else {
            log:printInfo("Sent request to Kafka successfully");
        }
    }
}