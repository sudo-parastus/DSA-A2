import ballerina/kafka;
import ballerina/log;
import logistics-system/modules/logistics as logistics;

public class RequestConsumer {
    private kafka:Consumer consumer;

    public function init() {
        self.consumer = new ({
            bootstrapServers: "localhost:9092",
            clientId: "delivery-request-consumer",
            groupId: "delivery-request-group",
            offsetReset: "earliest"
        });
    }

    public function start() {
        error? result = self.consumer->subscribe("delivery-requests");
        if (result is error) {
            log:printError("Failed to subscribe to Kafka topic: ", err = result);
            return;
        }

        log:printInfo("Listening for delivery requests...");

        while true {
            kafka:ConsumerRecord[]|error records = self.consumer->poll(100);
            if records is kafka:ConsumerRecord[] {
                foreach var record in records {
                    delivery:DeliveryRequest request = <delivery:DeliveryRequest>record.value;
                    log:printInfo("Received delivery request: ", request);

                    logistics:LogisticsService service = new();
                    service.handleDeliveryRequest(request);
                }
            } else {
                log:printError("Error while polling Kafka records: ", err = records);
            }
        }
    }
}