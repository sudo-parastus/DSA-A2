import ballerina/io;
import ballerina/graphql;

public function main() returns error? {

    io:println("----------------------------------------");
    io:println("1. Create user \n" +
                        "2. Already Have an Account Sign in \n"
                        );
    string option = io:readln();

    match option {
        "1" => {
            check createNewUser();
        }
        "2" => {
            string|error role = login();

            if (role is string) {
                match role {
                    "HoD" => {
                        check HoD();
                    }
                    "Supervisor" => {
                        check Supervisor();
                    }
                    "Employee" => {
                        check Employee();
                    }
                }

            } else if (role is error) {
                io:println("Wrong Credentials, Please enter correct credentials!!!");
                check main();
            }
        }
        _ => {
            io:println("Invalid Input");
            io:println("----------------------------------------");
            check main();
        }
    }
}

function HoD() returns error?{
    io:println("----------------------------------------");
                io:println("1. Create department objectives \n" +
                        "2. Delete department objectives \n" +
                        "3. View employee Score \n" +
                        "4. Assign the Employee to a supervisor \n"+
                        "5. Log out \n"
                        );
                string option = io:readln();

                match option{
                    "1" => {
                        check createObjective();
                    }
                    "2" => {
                        check deleteObjective();
                    }
                    "3" => {
                        check getTotalScore();
                    }
                    "4" => {
                        check assignSupervisor();
                    }
                    "5" => {
                        check main();
                    }
                    _ => {
                        io:println("Invalid Input");
                        io:println("----------------------------------------");
                        check HoD();
                    }
                }
}

function Supervisor() returns error?{
    io:println("----------------------------------------");
                io:println("1. Delete Employee's KPI \n" +
                        "2. Update Employee's KPI \n" +
                        "3. View Employee Score \n" +
                        "4. Grade Employee's KPI \n"+
                        "5. Log out \n"
                        );
                string option = io:readln();

                match option{
                    "1" => {
                        check deleteKPI();
                    }
                    "2" => {
                        check updateKPI();
                    }
                    "3" => {
                        check getScoreBySup();
                    }
                    "4" => {
                        check gradeKPI();
                    }
                    "5" => {
                        check main();
                    }
                    _ => {
                        io:println("Invalid Input");
                        io:println("----------------------------------------");
                        check Supervisor();
                    }
                }
}

function Employee() returns error?{
    io:println("----------------------------------------");
                io:println("1. Create KPI \n" +
                        "2. Grade your Supervisor \n" +
                        "3. View your Score \n" +
                        "4. Log out \n"
                        );
                string option = io:readln();

                match option{
                    "1" => {
                        check createKPI();
                    }
                    "2" => {
                        check gradeSupervisor();
                    }
                    "3" => {
                        check getScore();
                    }
                    "4" => {
                        check main();
                    }
                    _ => {
                        io:println("Invalid Input");
                        io:println("----------------------------------------");
                        check Employee();
                    }
                }
}

function createNewUser() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");
    
    io:println("----------------------------------------");
    io:println("Enter first name");
    string firstName = io:readln();

    io:println("Enter last name");
    string lastName = io:readln();

    io:println("Enter your Job title");
    string jobTitle = io:readln();

    io:println("Enter your role");
    string role = io:readln();

     io:println("----------------------------------------");
    io:println("Enter your staff Number");
    string staffNo = io:readln();

    io:println("Create a password");
    string password = io:readln();
    io:println("----------------------------------------");

    json user = {
        "staffNo": staffNo,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "jobTitle": jobTitle,
        "role": role
    };

    string mutationQuery = string `mutation AddUser($user: User!) {
         addUser(user: $user)
    }`;

    map<json> variables = {
        "user": user
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.addUser;
        io:println(message);
        check main();
    } else {
        io:println("A server error occured");
    }
}

function login() returns string|error{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Please enter your staff Number");
    string staffNo = io:readln();
    io:println("Enter your password");
    string password = io:readln();
    io:println("----------------------------------------");

    string query = string `
        query ($staffNo: String!, $password: String!) {
              login(staffNo: $staffNo, password: $password)
              }
           `;

    map<json> variables = {
        "staffNo": staffNo,
        "password": password
    };


    json|error response = check graphqlClient->execute(query,variables);

    if (response is json) {
        // Extract the role from the JSON response
        string role = check response.data.login;
        return role;
    } else {
        // Handle errors here
        return "An error occured";
        
    }
}

function createObjective() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");
    
    io:println("----------------------------------------");
    io:println("Enter the Department ID");
    string departmentId = io:readln();

    io:println("Enter the Objective ID");
    string objectiveID = io:readln();
     io:println("Describe the Objective");
    string description = io:readln();
    io:println("----------------------------------------");

    json objective = {
        "id": objectiveID,
        "description": description
    };

    string mutationQuery = string `mutation CreateDepartmentObjectives($departmentId: String!, $objective: Objective!){
        createDepartmentObjectives(departmentId: $departmentId, objective: $objective)
    }`;

    map<json> variables = {
        "departmentId": departmentId,
        "objective": objective
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.createDepartmentObjectives;
        io:println(message);
        check HoD();
    } else {
        io:println("A server error occured");
    }
}

function deleteObjective() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Enter the Department ID");
    string departmentID = io:readln();

    io:println("Enter the Objective ID");
    string objectiveID = io:readln();
    io:println("----------------------------------------");

        string mutationQuery = string `mutation DeleteDepartmentObjectives($departmentId: String!, $objectiveId: String!) {
  deleteDepartmentObjectives(departmentId: $departmentId, objectiveId: $objectiveId)
}`;

    map<json> variables = {
        "departmentId": departmentID,
        "objective": objectiveID
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.deleteDepartmentObjectives;
        io:println(message);
        check HoD();
    } else {
        io:println("An error occured");
    }
}


function getTotalScore() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Employee staff Number");
    string staffNumber = io:readln();
    io:println("----------------------------------------");

    string query = string `
    query ($staffNo: String!) {
        employeeTotalScore(staffNo: $staffNo)
   }`;

    map<json> variables = {
        "staffNo": staffNumber
    };

    json|error response = check graphqlClient->execute(query, variables);

    if (response is json) {
        string message = check response.data.employeeTotalScore;
        io:println("The employee grade is: ",message);
        check HoD();
    } else {
        io:println("An error occured");
    }
}

function assignSupervisor() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Enter employee staff Number");
    string employee = io:readln();

    io:println("Enter supervisor staff Number");
    string supervisor = io:readln();
    io:println("----------------------------------------");

    string mutationQuery = string `mutation AssignSupervisor($empStaffNo: String!, $supStaffNo: String!) {
          assignSupervisor(empStaffNo: $empStaffNo, supStaffNo: $supStaffNo)
          }`;
    
    map<json> variables = {
        "empStaffNo": employee,
        "supStaffNo": supervisor
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.assignSupervisor;
        io:println(message);
        check HoD();
    } else {
        io:println("An error occured");
    }
}

function deleteKPI() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Enter KPI ID");
    string id = io:readln();
    io:println("----------------------------------------");

    string mutationQuery = string `mutation DeleteKPI($id: String!) {
            deleteKPI(id: $id)
    }`;
    
    map<json> variables = {
        "id": id
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.deleteKPI;
        io:println(message);
        check Supervisor();
    } else {
        io:println("An error occured");
    }
}


function updateKPI() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Enter KPI ID");
    string id = io:readln();

    io:println("Enter KPI Description");
    string description = io:readln();

    io:println("Enter KPI grade out of 10");
    string grade = io:readln();

    io:println("Enter employee's staff Number");
    string employee_no = io:readln();

    io:println("Enter supervisor's staff Number");
    string supervisor_no = io:readln();

    io:println("Enter Department ID");
    string department_id = io:readln();
    io:println("----------------------------------------");

    string mutationQuery = string `mutation UpdateKPI(
  $id: String!
  $description: String!
  $grade: String!
  $employee_staffNo: String!
  $supervisor_staffNo: String!
  $department_id: String!
) {
  updateKPI(
    id: $id
    description: $description
    grade: $grade
    employee_staffNo: $employee_staffNo
    supervisor_staffNo: $supervisor_staffNo
    department_id: $department_id
  )
}
`;
    
    map<json> variables = {
        "id": id,
        "description": description,
        "grade": grade,
        "employee_staffNo": employee_no,
        "supervisor_staffNo": supervisor_no,
        "department_id": department_id
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.updateKPI;
        io:println(message);
        check Supervisor();
    } else {
        io:println("An error occured");
    }
}

function getScoreBySup() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Please enter your staff Number");
    string employee_no = io:readln();
    io:println("Please enter the supervisor Number");
    string supervisor_no = io:readln();
    io:println("----------------------------------------");

    string query = string `
         query ($empStaffNo: String!, $supStaffNo: String!) {
             employeeScore(empStaffNo: $empStaffNo, supStaffNo: $supStaffNo)
        } `;

    map<json> variables = {
        "empStaffNo": employee_no,
        "supStaffNo": supervisor_no
    };


    json|error response = check graphqlClient->execute(query,variables);

    if (response is json) {
        // Extract the role from the JSON response
        string message = check response.data.employeeScore;
        io:println("The employee grade is: ",message);
        check Supervisor();
    } else {
        io:println("An error occured");
    }
}

function gradeKPI() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Enter KPI ID");
    string id = io:readln();
    io:println("Enter KPI Grade out of 10");
    string grade = io:readln();
    io:println("----------------------------------------");

    string mutationQuery = string `mutation GradeKPI($KPIid: String!, $newGrade: String!) {
             gradeKPI(KPIid: $KPIid, newGrade: $newGrade)
        }`;
    
    map<json> variables = {
        "KPIid": id,
        "newGrade": grade
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.gradeKPI;
        io:println(message);
        check Supervisor();
    } else {
        io:println("An error occured");
    }
}

function createKPI() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Enter the KPI ID");
    string id = io:readln();

    io:println("Enter the description ID");
    string description = io:readln();

    io:println("Enter your staff NumberS");
    string employee_no = io:readln();

    io:println("Enter department ID");
    string department_id = io:readln();
    io:println("----------------------------------------");

    string mutationQuery = string `mutation CreateKPI($id: String!, $description: String!, $employee_staffNo: String!, $department_id: String!) {
              createKPI(id: $id, description: $description, employee_staffNo: $employee_staffNo, department_id: $department_id)
    }`;

    map<json> variables = {
        "id": id,
        "description": description,
        "employee_staffNo": employee_no,
        "department_id": department_id
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.createKPI;
        io:println(message);
        check Employee();
    } else {
        io:println("An error occured");
    }
}

function gradeSupervisor() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");
    
    io:println("----------------------------------------");
    io:println("Enter the Department ID");
    string supStaffNo = io:readln();

    io:println("Enter the Objective ID");
    string grade = io:readln();
    io:println("----------------------------------------");

    string mutationQuery = string `mutation GradeSupervisor($supStaffNo: String!, $newGrade: String!) {
            gradeSupervisor(supStaffNo: $supStaffNo, newGrade: $newGrade)
    }`;

    map<json> variables = {
        "supStaffNo": supStaffNo,
        "newGrade": grade
    };

    json|error response = check graphqlClient->execute(mutationQuery, variables);

    if (response is json) {
        string message = check response.data.gradeSupervisor;
        io:println(message);
        check Employee();
    } else {
        io:println("An error occured");
    }
}

function getScore() returns error?{

    graphql:Client graphqlClient = check new ("localhost:9090");

    io:println("----------------------------------------");
    io:println("Please enter your staff Number");
    string employee_no = io:readln();
    io:println("----------------------------------------");

    string query = string `
         query ($empStaffNo: String!) {
           getScore(empStaffNo: $empStaffNo)
    }`;

    map<json> variables = {
        "empStaffNo": employee_no
    };


    json|error response = check graphqlClient->execute(query,variables);

    if (response is json) {
        // Extract the role from the JSON response
        string message = check response.data.getScore;
        io:println("Your grade:",message);
        check Employee();
    } else {
        io:println("An error occured");
    }
}
