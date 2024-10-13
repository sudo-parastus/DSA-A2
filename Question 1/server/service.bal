import ballerina/graphql;
import ballerinax/mongodb;

//Establishing a connection with mongoDB database
mongodb:ConnectionConfig mongoConfig = {
    connection: {
        host: "localhost",
        port: 27017,
        auth: {
            username: "",
            password: ""
        },
        options: {
            sslEnabled: false,
            serverSelectionTimeout: 5000
        }
    },
    databaseName: "PMS"
};

mongodb:Client db = check new (mongoConfig);

configurable string departmentCollection = "Departments";
configurable string userCollection = "Users";
configurable string KPIcollection = "KPIs";
configurable string databaseName = "PMS";

// Below are Ballerina records of the data we are using

type LoggedUserDetails record {|
    string role;
|};

type User record {
    string staffNo;
    string password;
    string firstName;
    string lastName;
    string jobTitle;
    string role;
};

type Department record {
    string id;
    string name;
    Objective objectives;
};

type Objective record {
    string id;
    string description;
};

type KPI record {
    string id;
    string description;
    string grade;
    string employee_staffNo;
    string supervisor_staffNo;
    string department_id;
};

service / on new graphql:Listener(9090) {

    remote function addUser(User user) returns string|error {
        map<json> doc = <map<json>>{staffNo: user.staffNo, password: user.password, firstName: user.firstName, lastName: user.lastName, jobTitle: user.jobTitle, role: user.role};
        _ = check db->insert(doc, userCollection, "");
        return string `${user.staffNo} added successfully`;
    }

    // The following are the functions of a HoD
    remote function createDepartmentObjectives(string departmentId, Objective objective) returns string|error {

        var filter = {id: departmentId};
        map<json> newObjective = <map<json>>{"$push": {"objectives": {id: objective.id, description: objective.description}}};

        int updatedCount = check db->update(newObjective, departmentCollection, databaseName, filter, true, false);

        if updatedCount > 0 {
            return string `Objective has been added successfully`;
        }
        return "Failed to add the Objective";
    }

    remote function deleteDepartmentObjectives(string departmentId, string objectiveId) returns string|error {

        var filter = {id: departmentId};
        map<json> delObjective = <map<json>>{"$pull": {"objectives": {id: objectiveId}}};

        int updatedCount = check db->update(delObjective, departmentCollection, databaseName, filter, true, false);

        if updatedCount > 0 {
            return string `${objectiveId} has been deleted successfully`;
        }
        return "Failed to updated";
    }

    resource function get employeeTotalScore(string staffNo) returns string|error {

        var filter = {employee_staffNo: staffNo};
        stream<KPI, error?> KPIrecord = check db->find(KPIcollection, databaseName, filter,{});

        KPI[] records = check from var kpiRecord in KPIrecord select kpiRecord;

        if records.length() > 0 {
            return records[0].grade.toString();
        }
        return "N/A";
    }

    remote function assignSupervisor(string empStaffNo, string supStaffNo) returns string|error {

        var filter = {employee_staffNo: empStaffNo};
        map<json> assignSupervisor = <map<json>>{"$set": {"supervisor_staffNo": supStaffNo}};

        int updatedCount = check db->update(assignSupervisor, KPIcollection, databaseName, filter, true, false);

        if updatedCount > 0 {
            return string `${empStaffNo} has been assigned to ${supStaffNo}`;
        }
        return "Failed to assign Supervisor";
    }

    //The following functions are for the Supervisor

    remote function deleteKPI(string id) returns error|string {

        var filter = {id: id};

        mongodb:Error|int deleteItem = db->delete(KPIcollection, databaseName, filter, false);

        if deleteItem is mongodb:Error {
            return error("Failed to delete items");
        } else {
            if deleteItem > 0 {
                return string `${id} deleted successfully`;
            } else {
                return string `Specified ID number does not Exist`;
            }
        }
    }

    remote function updateKPI(string id, string description,string grade, string employee_staffNo,string supervisor_staffNo, string department_id) returns string|error{
        
        var filter = {id: id};
        map<json> changeKPI = <map<json>>{"$set": {"id": id, "description": description, "grade": grade, "employee_staffNo": employee_staffNo, "supervisor_staffNo": supervisor_staffNo, "department_id": department_id}};

        int updatedCount = check db->update(changeKPI, KPIcollection, databaseName, filter, true, false);

                if updatedCount > 0 {
            return string `The update to ID ${id} was successfull`;
        }
        return "Failed Update";
    }

    resource function get employeeScore(string empStaffNo, string supStaffNo) returns string|error {

        var filter = {employee_staffNo: empStaffNo, supervisor_staffNo: supStaffNo};
        stream<KPI, error?> KPIrecord = check db->find(KPIcollection, databaseName, filter,{});

        KPI[] records = check from var userRecord in KPIrecord
            select userRecord;

        if records.length() > 0 {
            return records[0].grade.toString();
        }
        return "N/A";
    }

        remote function gradeKPI(string KPIid, string newGrade) returns string|error{
        
        var filter = {id: KPIid};
        map<json> changeKPIgrade = <map<json>>{"$set": {"grade": newGrade}};

        int updatedCount = check db->update(changeKPIgrade, KPIcollection, databaseName, filter, true, false);

        if updatedCount > 0 {
            return string `The grade of ID ${KPIid} has been successfully updated to ${newGrade}`;
        }
        return "Failed to grade the KPI";
    }

// The folowing are the function of the User

    remote function createKPI(string id, string description, string employee_staffNo, string department_id) returns string|error {
        map<json> doc = <map<json>>{id: id, description: description, employee_staffNo: employee_staffNo, department_id: department_id};
        _ = check db->insert(doc, KPIcollection, "");
        return string `${id} added successfully`;
    }

    remote function gradeSupervisor(string supStaffNo, string newGrade) returns string|error{

        var filter = {staffNo: supStaffNo};
        map<json> changeSupervisorGrade = <map<json>>{"$set": {"grade": newGrade}};

        int updatedCount = check db->update(changeSupervisorGrade, userCollection, databaseName, filter, true, false);

        if updatedCount > 0 {
            return string `The grade of ID ${supStaffNo} has been successfully updated to ${newGrade}`;
        }
        return "Failed to grade your Supervisor";
    }

    resource function get getScore(string empStaffNo) returns string|error {

        var filter = {employee_staffNo: empStaffNo};
        stream<KPI, error?> KPIrecord = check db->find(KPIcollection, databaseName, filter,{});

        KPI[] records = check from var userRecord in KPIrecord select userRecord;

        if records.length() > 0 {
            return records[0].grade.toString();
        }
        return "N/A";
    }

// Authentication funtions

    resource function get login(string staffNo, string password) returns string|error {
        var filter = {staffNo: staffNo, password: password};
        stream<User, error?> retrievedUser = check db->find(userCollection, databaseName, filter, {});

        User[] users = check from var userInfo in retrievedUser select userInfo;
        if users.length() > 0 {
            return users[0].role.toString();

        } 
            return error("User not found");
    }
}
