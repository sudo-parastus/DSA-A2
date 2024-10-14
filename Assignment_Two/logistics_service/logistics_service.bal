import ballerina/http;
import ballerinax/kafka;
import ballerinax/mongodb;
import ballerina/io;

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

type DeliveryResponse record {
    string message;
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

        io:println("Published pickup request to Kafka topic " + topic + ": " + shipment.shipmentId);
        return {message: "Pickup request is being processed", shipmentId: shipment.shipmentId};
    }
}

