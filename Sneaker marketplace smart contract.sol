// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SneakerMarketplace {
    address public owner;
    uint public sneakerCount = 0;

    struct Sneaker {
        string brand;
        string model;
        string size; // Now a string to support half sizes, e.g., "9.5"
        address currentOwner;
        bool forSale;
        uint price;
    }

    mapping(uint => Sneaker) public sneakers;

    // Events for logging actions
    event SneakerAdded(uint sneakerId, string brand, string model, string size, uint price);
    event SneakerPurchased(uint sneakerId, address previousOwner, address newOwner, uint price);
    event SneakerForSaleUpdated(uint sneakerId, bool forSale, uint price);

    constructor() {
        owner = msg.sender;
    }

    // Add one or more sneakers with an initial price
    function addSneakers(string memory brand, string memory model, string memory size, uint quantity, uint price) public {
        require(msg.sender == owner, "Only the owner can add sneakers to the marketplace.");
        for (uint i = 0; i < quantity; i++) {
            sneakers[sneakerCount] = Sneaker(brand, model, size, msg.sender, true, price);
            emit SneakerAdded(sneakerCount, brand, model, size, price);
            sneakerCount++;
        }
    }

    // Purchase a sneaker if it is for sale and the sent value meets the price requirement
    function buySneakers(uint sneakerId) public payable {
        Sneaker storage sneaker = sneakers[sneakerId];
        require(sneaker.forSale, "Sneaker is not for sale.");
        require(msg.value >= sneaker.price, "Insufficient ether to purchase sneakers.");

        address previousOwner = sneaker.currentOwner;

        // Transfer funds to the previous owner
        payable(previousOwner).transfer(msg.value);

        // Update sneaker details: new owner and mark it as not for sale
        sneaker.currentOwner = msg.sender;
        sneaker.forSale = false;

        emit SneakerPurchased(sneakerId, previousOwner, msg.sender, sneaker.price);
    }

    // Allow the current owner to update the sale status and price of a sneaker
    function setForSale(uint sneakerId, bool forSale, uint price) public {
        Sneaker storage sneaker = sneakers[sneakerId];
        require(msg.sender == sneaker.currentOwner, "Only the current owner can update the sale status.");
        sneaker.forSale = forSale;
        sneaker.price = price;
        emit SneakerForSaleUpdated(sneakerId, forSale, price);
    }
}
