// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract HospitalManagement is Ownable {
    struct Patient {
        string name;
        uint256 age;
        string medicalHistory;
    }

    struct Appointment {
        uint256 date;
        string description;
        bool completed;
    }

    mapping(address => Patient) public patients;
    mapping(address => mapping(uint256 => Appointment)) public appointments;
    mapping(address => uint256) public appointmentCount;

    event PatientAdded(address indexed patientAddress, string name, uint256 age);
    event AppointmentScheduled(address indexed patientAddress, uint256 date, string description);
    event AppointmentCompleted(address indexed patientAddress, uint256 appointmentId);

    constructor() Ownable(msg.sender) {}

    function addPatient(
        address patientAddress,
        string memory name,
        uint256 age,
        string memory medicalHistory
    ) external onlyOwner {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(age > 0, "Age must be greater than zero");

        patients[patientAddress] = Patient(name, age, medicalHistory);
        emit PatientAdded(patientAddress, name, age);
    }

    function scheduleAppointment(
        address patientAddress,
        uint256 date,
        string memory description
    ) external onlyOwner {
        require(bytes(description).length > 0, "Description cannot be empty");
        require(patients[patientAddress].age > 0, "Patient does not exist");

        uint256 appointmentId = appointmentCount[patientAddress];
        appointments[patientAddress][appointmentId] = Appointment(date, description, false);
        appointmentCount[patientAddress]++;

        emit AppointmentScheduled(patientAddress, date, description);
    }

    function completeAppointment(
        address patientAddress,
        uint256 appointmentId
    ) external onlyOwner {
        require(appointmentId < appointmentCount[patientAddress], "Appointment does not exist");
        require(!appointments[patientAddress][appointmentId].completed, "Appointment already completed");

        appointments[patientAddress][appointmentId].completed = true;
        emit AppointmentCompleted(patientAddress, appointmentId);
    }

    function getPatientDetails(address patientAddress) external view returns (Patient memory) {
        return patients[patientAddress];
    }

    function getAppointmentDetails(address patientAddress, uint256 appointmentId) external view returns (Appointment memory) {
        return appointments[patientAddress][appointmentId];
    }
}