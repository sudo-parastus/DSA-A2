import ballerina/mongodb;
import ballerina/log;
import logistics-system/modules/delivery as delivery;

public class MongoDBManager {
    private mongodb:Client mongoClient;

    public function init() {
        self.mongoClient = check new ({
            host: "localhost",
            port: 27017,
            user: "your-username",
            password: "your-password",
            database: "logistics"
        });
    }

    public function storeDeliveryRequest(delivery:DeliveryRequest request) {
        // Convert the DeliveryRequest to a MongoDB document
        map<any> document = {
            "shipmentType": request.shipmentType,
            "pickupLocation": request.pickupLocation,
            "deliveryLocation": request.deliveryLocation,
            "preferredTimeSlots": request.preferredTimeSlots,
            "customerFirstName": request.customerFirstName,
            "customerLastName": request.customerLastName,
            "customerContact": request.customerContact
        };

        // Insert the document into the 'delivery_requests' collection
        error? result = self.mongoClient->insert("delivery_requests", document);
        if (result is error) {
            log:printError("Failed to store delivery request in MongoDB: ", err = result);
        } else {
            log:printInfo("Stored delivery request in MongoDB successfully");
        }
    }

    public function storeDeliverySchedule(delivery:PickupAndDeliverySchedule schedule) {
        // Convert the PickupAndDeliverySchedule to a MongoDB document
        map<any> document = {
            "trackingNumber": schedule.trackingNumber,
            "pickupTime": schedule.pickupTime,
            "deliveryTime": schedule.deliveryTime
        };

        // Insert the document into the 'delivery_schedules' collection
        error? result = self.mongoClient->insert("delivery_schedules", document);
        if (result is error) {
            log:printError("Failed to store delivery schedule in MongoDB: ", err = result);
        } else {
            log:printInfo("Stored delivery schedule in MongoDB successfully");
        }
    }
}