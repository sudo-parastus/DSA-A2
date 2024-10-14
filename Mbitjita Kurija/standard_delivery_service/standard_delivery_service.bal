import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerinax/kafka;
import ballerinax/mongodb;
import ballerina/time;

type Shipment record {
    string shipmentId;
    string pickupLocation;
    string deliveryLocation;
    string preferredTimeSlots;
    string requestStatus;
    string typeOfShipment; // "standard", "express", or "international"
    Customer customer;
};

type Customer record {
    string firstName;
    string lastName;
    string contactNumber;
    string email;
    string address;
};

// Function to check availability dynamically (stub function)
function checkAvailability() returns string|error {
    // Get the current time
    time:Utc currentTime = time:utcNow();
    return currentTime.toString();
}

public function main() returns error? {
    kafka:Consumer shipmentConsumer = check new ("localhost:9092", {
        groupId: "delivery-group-id",
        topics: "standard-delivery"
    });

    // Initialize MongoDB client (replace with your MongoDB URI)
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
        where 'shipment.requestStatus == "pending" // Only process pending shipments
        do {
            // Log the received shipment request
            log:printInfo("Received shipment request for delivery: " + shipment.toString());

            // Simulate checking availability
            string availableTime = check checkAvailability();

            // Prepare the response
            json response = {
                "message": "Accepted by Standard Delivery"
            };

            // Send the response back to the Central Logistics Service
            http:Client logisticsClient = check new ("http://localhost:8080");
            http:Response|error post = logisticsClient->post("/deliveryResponse", response);

            if post is error {
                log:printError("Failed to send response to logistics service: " + post.toString());
            } else {
                log:printInfo("Response sent to logistics service successfully.");
            }

            // Update shipment status in MongoDB
            mongodb:Update updateData = {
                "$set": {
                    "requestStatus": "Confirmed",
                    "availableTime": availableTime
                }
            };
            mongodb:Database database = check mongoDbClient->getDatabase("logisticsDB");
            mongodb:Collection collection = check database->getCollection("shipments");
            _ = check collection->updateOne({"shipmentId": shipment.shipmentId}, updateData);

            io:println(string `Processed shipment for customer ID: ${shipment.shipmentId}`);
        };
    }
}

