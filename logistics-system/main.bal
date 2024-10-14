import ballerina/log;
import logistics-system/modules/kafka as kafka;
import logistics-system/modules/logistics as logistics;

public function main() {
    log:printInfo("Starting logistics system");

    kafka:RequestProducer producer = new();
    kafka:RequestConsumer consumer = new();

    // Start the Kafka consumer to listen for incoming requests
    consumer.start();
}