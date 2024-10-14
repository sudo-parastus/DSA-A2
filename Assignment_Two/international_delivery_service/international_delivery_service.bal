import ballerina/io;
import ballerina/time;
import ballerinax/kafka;
import ballerinax/mongodb;

type Shipment record {
    string shipmentId;
    string pickupLocation;
    string deliveryLocation;
    string requestStatus;
    string typeOfShipment;
    Customer customer;
};

type Customer record {
    string fullName;
    string email;
    string address;
};

// Function to check availability dynamically (stub function)
function checkAvailability() returns string|error {
    // Get the current time
    time:Civil currentTime = time:utcToCivil(time:utcNow());
    return currentTime.toString();
}

public function main() returns error? {
    kafka:Consumer shipmentConsumer = check new ("localhost:9092", {
        groupId: "delivery-group-id",
        topics: "international-delivery"
    });

    // Initialize MongoDB client
    mongodb:Client mongoDbClient = check new ({
        connection: {
            serverAddress: {
                host: "localhost",
                port: 27017
            },
            auth: <mongodb:ScramSha256AuthCredential>{
                username: "mongoadmin",
                password: "secret",
                database: "logisticsDB"
            }
        }
    });

    while true {
        // Poll the consumer for shipment payloads
        Shipment[] shipments = check shipmentConsumer->pollPayload(15);

        from Shipment shipment in shipments
        where 'shipment.requestStatus == "Pending" // Only process pending shipments
        do {
            // Log the received shipment request
            io:println("Received international shipment request for delivery: " + shipment.toString());

            // Simulate checking availability
            string availableTime = check checkAvailability();

            // Update shipment status in MongoDB
            mongodb:Update updateData = {
                set: {
                    requestStatus: "Confirmed",
                    availableTime: availableTime
                }
            };

            mongodb:Database database = check mongoDbClient->getDatabase("logisticsDB");
            mongodb:Collection collection = check database->getCollection("shipments");
            _ = check collection->updateOne({"shipmentId": shipment.shipmentId}, updateData);

            io:println(string `Processed international shipment for customer ID: ${shipment.shipmentId}`);
        };
    }
}
