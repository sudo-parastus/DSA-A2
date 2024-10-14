import ballerina/io;
import ballerina/http;
import ballerina/random;

// Define the Shipment and Customer record types
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

// Define the response type from the logistics service
type PickupResponse record {
    string message;
    string shipmentId;
};

// Create a client for the Logistics Service running on http://localhost:8080
http:Client logisticsClient = check new ("http://localhost:8080/logistics");

int randomNumber = check random:createIntInRange(1000, 5000);
string shipmentIdValue = string `SH${randomNumber}`;

public function main() returns error? {
    io:println("----------------------------------------");
    io:println("Logistics Service Client");
    io:println("----------------------------------------");
    io:println("1. Request Pickup\n" +
               "2. Exit");
    io:println("----------------------------------------");
    io:println("Choose your OPTION");
    string option = io:readln();

    match option {
        "1" => {
            check requestPickup();
            // Return to the main menu
            check main();
        }
        "2" => {
            io:println("Exiting...");
        }
        _ => {
            io:println("INVALID OPTION");
            // Return to the main menu
            check main();
        }
    }
}

// Function to request a pickup
function requestPickup() returns error? {
    io:println("Enter Pickup Location");
    string pickupLocation = io:readln();
    io:println("Enter Delivery Location");
    string deliveryLocation = io:readln();
    io:println("Choose Type of Shipment:");
    io:println("1. Standard");
    io:println("2. Express");
    io:println("3. International");
    io:println("Enter the number corresponding to your choice:");
    string shipmentTypeChoice = io:readln();
    string typeOfShipment;

    if shipmentTypeChoice == "1" {
        typeOfShipment = "standard";
    }else if shipmentTypeChoice == "2" {
        typeOfShipment = "express";
    }else if shipmentTypeChoice == "3" {
        typeOfShipment = "international";
    }else {
        typeOfShipment = "standard";
    }

    // Customer details
    io:println("----------------------------------------");
    io:println("CUSTOMER DETAILS");    
    io:println("----------------------------------------");
    io:println("Enter Customer FullName");
    string fullName = io:readln();
    io:println("Enter Customer Email");
    string email = io:readln();
    io:println("Enter Customer Address");
    string address = io:readln();

    // Populate the shipment and customer data
    Customer customer = {
        fullName: fullName,
        email: email,
        address: address
    };

    Shipment shipment = {
        shipmentId: shipmentIdValue+customer.email,
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        requestStatus: "Pending",
        typeOfShipment: typeOfShipment,
        customer: customer
    };

    // Send the pickup request to the logistics service
    PickupResponse|error response = logisticsClient->post("/pickupRequest", shipment);

    if response is PickupResponse {
        io:println("Pickup Request Response: ", response.message);
        io:println("Shipment ID: ", response.shipmentId);
    } else {
        io:println("Failed to send pickup request: ", response.toString());
    }
}

