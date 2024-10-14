import ballerina/http;


public type Shipment record {
    string customerId;
    string pickupLocation;
    string deliveryLocation;
    string preferredTimeSlots;
    string requestStatus;
    Customer customer;
};

public type Customer record {
    string firstName;
    string lastName;
    string contactNumber;
    string email;
    string address;
};
service /expressDelivery on new http:Listener(8082) {
    resource function post checkAvailability(Shipment shipment) returns json|error {
        return {
            "type": "Express Delivery",
            "availableTime": "2024-10-14T15:00:00Z"
        };
    }
}