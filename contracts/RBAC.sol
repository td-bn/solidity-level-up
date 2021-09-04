// SPDX-License-Identifier: MIT 

pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";


contract Office is AccessControlEnumerable {
    bytes32 public constant DIRECTOR_ROLE = keccak256("DIRECTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    mapping (address=>bool) public activeEmployees;

    constructor (address _director, address _manager) {
        _setupRole(DIRECTOR_ROLE, _director);
        _setupRole(MANAGER_ROLE, _manager);
        _setRoleAdmin(MANAGER_ROLE, DIRECTOR_ROLE);

        activeEmployees[_director] = true;
        activeEmployees[_manager] = true;
    }

    function addEmployee(address _employee) public onlyRole(MANAGER_ROLE) {
        activeEmployees[_employee] = true;
    }

    function addManager(address _employee) public onlyRole(DIRECTOR_ROLE) {
        activeEmployees[_employee] = true;
        grantRole(MANAGER_ROLE, _employee);
    }
}
