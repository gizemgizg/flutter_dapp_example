// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract UsersContract {
    uint256 public userCount = 0;

    struct User {
        uint256 id;
        string name;
        string surname;
    }

    mapping(uint256 => User) public users;

    event UserCreated(uint256 id, string name, string surname);
    event UserDeleted(uint256 id);

    function createUser(string memory _name, string memory _surname) public {
            users[userCount] = User(userCount, _name, _surname);
            emit UserCreated(userCount, _name, _surname);
            userCount++;
    }

    function deleteUser(uint256 _id) public{
        delete users[_id];
        emit UserDeleted(_id);
        userCount--;
    }
}
