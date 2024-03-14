pragma solidity ^0.8.0;

contract SneakerMarketplace {
    address public owner;

    struct Sneaker {
        string brand;
        string model;
        uint8 size;
        address owner;
        bool forSale;
    }

    mapping(address => Sneaker) public sneakers;

    constructor() {
        owner = msg.sender;
    }

    function addSneakers(string memory brand, string memory model, uint8 size, uint quantity) public {
        require(msg.sender == owner, "Only the owner can add sneakers to the marketplace.");
        for (uint i = 0; i < quantity; i++) {
            address newSneaker = address(uint(keccak256(abi.encodePacked(block.timestamp, i))) % 10**20);
            sneakers[newSneaker] = Sneaker(brand, model, size, msg.sender, true);
        }
    }

    function buySneakers(address sneakerId) public payable {
        Sneaker storage sneaker = sneakers[sneakerId];
        require(sneaker.forSale, "Sneaker is not for sale.");
        require(msg.value >= 100 ether, "Insufficient ether to purchase sneakers.");
        sneaker.forSale = false;
        sneaker.owner.transfer(msg.value);
    }
}

