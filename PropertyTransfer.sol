// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PropertyTransfer {

    address public admin; // Changed from owner to avoid confusion

    constructor() {
        admin = msg.sender;
    }

    modifier OnlyAdmin() {
        require(admin == msg.sender, "Not admin");
        _;
    }

    modifier OnlyCurrentOwner(uint id) {
        require(properties[id].currentOwner == msg.sender, "Not current owner");
        _;
    }

    struct Property {
        string name;
        address currentOwner;
        string location;
        uint price;
        address[] previousOwners;
    }

    mapping(uint => Property) public properties;
    mapping(uint => address) public pendingBuyers;

    event PropertyAdded(uint id, string name, string location, uint price, address currentOwner);
    event BuyerDepositted(uint id, address buyer, uint amount);
    event OwnershipTransferred(uint id, address seller, address buyer, uint newPrice);
    event RefundIssued(uint id, address buyer, uint amount);


    // Add property by admin only
    function addProperty(uint id, string memory _name, string memory _location, uint _price) public OnlyAdmin {
        Property storage prop = properties[id];
        prop.name = _name;
        prop.location = _location;
        prop.currentOwner = admin;
        prop.price = _price;
        prop.previousOwners.push(admin);

        emit PropertyAdded(id, _name, _location, _price, admin);
    }

    // View property info with full ownership history
    function getPropertyInfo(uint id) public view returns (
        string memory,
        address,
        string memory,
        uint,
        address[] memory
    ) {

        require(properties[id].currentOwner != address(0), "Property does not exist");

        Property storage prop = properties[id];
        return (
            prop.name,
            prop.currentOwner,
            prop.location,
            prop.price,
            prop.previousOwners
        );
    }

    // Buyer expresses interest and sends funds (escrow)
    function buyProperty(uint id) public payable {
        Property storage prop = properties[id];
        require(prop.price == msg.value, "Price incorrect");
        require(msg.sender != prop.currentOwner, "Already owner");
        require(pendingBuyers[id] == address(0), "Already pending");
        require(prop.currentOwner != address(0), "No such property");

        pendingBuyers[id] = msg.sender;

        emit BuyerDepositted(id, msg.sender, prop.price);
    }


    // Refund function allows a buyer to cancel their purchase request and get their ETH back before ownership is transferred
function refund(uint id) public {
    address buyer = pendingBuyers[id];
    require(buyer != address(0), "No pending buyer");
    require(msg.sender == buyer, "Only the buyer can request refund");

    Property storage prop = properties[id];
    uint amount = prop.price;

    //  Prevent reentrancy by deleting state before transferring ETH
    delete pendingBuyers[id];

    // Refund the buyer
    payable(buyer).transfer(amount);

    emit RefundIssued(id, buyer, amount);
}



    // Seller confirms and transfers ownership, receives funds
    function transferOwnership(uint id) public OnlyCurrentOwner(id) {
        Property storage prop = properties[id];
        address buyer = pendingBuyers[id];
        require(buyer != address(0), "No buyer has paid");

        // Transfer funds from contract to current owner
        payable(msg.sender).transfer(prop.price);

        // Ownership transfer
        prop.currentOwner = buyer;
        prop.previousOwners.push(buyer);

        // Price increment by 0.1 ether
        prop.price += 0.1 ether;

        // Reset pending buyer
        delete pendingBuyers[id];

        emit OwnershipTransferred(id, msg.sender, buyer, prop.price);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPendingBuyer(uint id) public view returns (address) {
        return pendingBuyers[id];
    }
}
