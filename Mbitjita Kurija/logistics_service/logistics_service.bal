import ballerina/http;
import ballerina/log;
import ballerinax/kafka;
import ballerinax/mongodb;

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

type DeliveryStatus record {
    string shipmentId;
    string availableTime;
    string status;
};

type DeliveryResponse record {
    string shipmentId;
    string availableTime;
};

// MongoDB client for database operations
mongodb:Client mongoDb = check new ({
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

// Central Logistics Service to handle pickup requests and responses
service /logistics on new http:Listener(8080) {
    private final kafka:Producer kafkaProducer;

    function init() returns error? {
        self.kafkaProducer = check new ("localhost:9092");
    }

    resource function post pickupRequest(Shipment shipment) returns json|error {
        // Save the shipment request to the database
        mongodb:Database database = check mongoDb->getDatabase("logisticsDB");
        mongodb:Collection collection = check database->getCollection("shipments");
        check collection->insertOne(shipment);

        // Publish the shipment to the Kafka topic based on the type
        string topic = shipment.typeOfShipment + "-delivery";
        check self.kafkaProducer->send({
            topic: topic,
            value: shipment
        });

        log:printInfo("Published pickup request to Kafka topic " + topic + ": " + shipment.shipmentId);
        return {message: "Pickup request is being processed", shipmentId: shipment.shipmentId};
    }

    // Handle delivery responses from delivery services
    resource function post deliveryResponse(DeliveryResponse response) returns error? {
        log:printInfo("Received delivery response: " + response.toString());

        // Extract relevant information from the response record
        string shipmentId = response.shipmentId;
        string availableTime = response.availableTime;

        // Prepare the update data
        mongodb:Update updateData = {
            set: {
                requestStatus: "Confirmed",
                availableTime: availableTime
            }
        };

        // Update the shipment status in the database
        mongodb:Database database = check mongoDb->getDatabase("logisticsDB");
        mongodb:Collection collection = check database->getCollection("shipments");

        // Perform the update operation
        _ = check collection->updateOne({"shipmentId": shipmentId}, updateData);

        // Prepare and log the final response for this shipment
        json finalResponse = {
            "message": "Delivery confirmed",
            "shipmentId": shipmentId,
            "availableTime": availableTime,
            "status": "Confirmed"
        };

        log:printInfo("Final delivery response sent to the customer: " + finalResponse.toString());
    }

}

