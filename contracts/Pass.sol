// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPreviousCollection {
    function balanceOf(address owner) external view returns (uint256);
}

contract Pass is ERC1155, Ownable {
    uint256 public nextPassId = 0;
    uint256 public passDuration = 365 days;
    uint256 public priceInc = .0005 ether;

    // Mapping from pass ID to its price
    mapping(uint256 => uint256) public passPrice;

    // Mapping from pass ID to its sale start time
    mapping(uint256 => uint256) public passSaleStartTime;

    // Mapping from user address and pass ID to its expiration time
    mapping(address => mapping(uint256 => uint256)) public passExpirationTime;


    address public previousCollectionAddress;



    constructor() ERC1155("https://ipfs.io/ipfs/QmPDQhkcyobcuf7DwTobAiqf84W2uGQ1rregKSrXX5s3Cw/{id}.json") {}

    // Overriding the safeTransferFrom function to handle expiration time during transfers
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
        super.safeTransferFrom(from, to, id, amount, data);

        // Check if the transferred token has an expiration time
        if (passExpirationTime[from][id] != 0) {
            // Transfer the expiration time to the new owner
            passExpirationTime[to][id] = passExpirationTime[from][id];

            // Reset the expiration time for the original owner
            delete passExpirationTime[from][id];
        }
    }

    // Overriding the safeBatchTransferFrom function to handle expiration times during batch transfers
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];

            // Check if the transferred token has an expiration time
            if (passExpirationTime[from][id] != 0) {
                // Transfer the expiration time to the new owner
                passExpirationTime[to][id] = passExpirationTime[from][id];

                // Reset the expiration time for the original owner
                delete passExpirationTime[from][id];
            }
        }
    }


    function setPassPrice(uint256 passId, uint256 _price) public onlyOwner {
        passPrice[passId] = _price;
    }

    function setPreviousCollectionAddress(address _previousCollectionAddress) external onlyOwner {
        previousCollectionAddress = _previousCollectionAddress;
    }

    function getPriceInc() public view returns (uint256) {
        return priceInc;
    }


    //change to internal when done testing
    function ownsPreviousCollectionNFT(address _user) public view returns (bool) {
        IPreviousCollection prevCollection = IPreviousCollection(previousCollectionAddress);
        return prevCollection.balanceOf(_user) > 0;
    }

    function getPassPrice(uint256 passId,uint256 qty) public view returns (uint256) {
        uint256 passesLeft = balanceOf(owner(), passId);
        uint256 currPrice = passPrice[passId];

        uint256 passesLeftCurrPrice = passesLeft % 5;
        if(passesLeftCurrPrice == 0){
            passesLeftCurrPrice = 5;
        }

        if(qty <= passesLeftCurrPrice){
            return currPrice * qty;
        }
        
        uint256 totalPrice = passesLeftCurrPrice * currPrice;

        currPrice += priceInc;

        uint256 restOfPasses = qty - passesLeftCurrPrice;

        uint256 numPriceInc = restOfPasses / 5;

        uint256 remain = restOfPasses % 5;

        for(uint i = 0; i < numPriceInc;i++){
            totalPrice += currPrice * 5;
            currPrice += priceInc;
        }

        totalPrice += remain * currPrice;

        return totalPrice;
    }

    // Users can buy a pass by sending ether
    function purchasePass(uint256 passId, uint qty) public payable {
        require(ownsPreviousCollectionNFT(msg.sender) == true);
        require(msg.value >= getPassPrice(passId,qty), "Passes: Incorrect Ether sent");
        require(balanceOf(owner(), passId) > 0, "Passes: Out of stock");
        require(block.timestamp >= passSaleStartTime[passId], "Passes: Sale has not started for this pass");

        uint256 passesLeft = balanceOf(owner(), passId);
        uint256 passesLeftCurrPrice = passesLeft % 5;
        if(passesLeftCurrPrice == 0){
            passesLeftCurrPrice = 5;
        }
        if(qty >= passesLeftCurrPrice){
            uint256 restOfPasses = qty - passesLeftCurrPrice;
            uint256 numPriceInc = restOfPasses/5 + 1;
            passPrice[passId] += numPriceInc* priceInc;
        }

        // Transfer the NFT to the purchaser
        _safeTransferFrom(address(owner()), msg.sender, passId, qty, "");

        // Set the expiration time for the pass for this specific user
        passExpirationTime[msg.sender][passId] = block.timestamp + passDuration;

        // Transfer the payment to the owner
        payable(owner()).transfer(msg.value);
    }


    // Users can reactivate an expired pass
    function reactivatePass(uint256 passId) public payable {
        require(msg.value == passPrice[passId], "Passes: Incorrect Ether sent");
        require(balanceOf(msg.sender, passId) > 0, "Passes: You don't own this pass");
        require(block.timestamp > passExpirationTime[msg.sender][passId], "Passes: This pass has not expired yet");

        // Reset the expiration time for the pass for this specific user
        passExpirationTime[msg.sender][passId] = block.timestamp + passDuration;

        // Transfer the payment to the owner
        payable(owner()).transfer(msg.value);
    }

    // Owner can mint new passes in advance and set a sale start time
    // Updated mintPass function to include price setting
    function mintPass(uint256 amount, uint256 saleStartTime, uint256 _price, bytes memory data) public onlyOwner {
        require(saleStartTime >= block.timestamp, "Passes: Sale start time should be in the future");

        // Set the price for the newly minted pass
        passPrice[nextPassId] = _price;

        _mint(address(owner()), nextPassId, amount, data);  // Minting to the contract itself
        passSaleStartTime[nextPassId] = saleStartTime;
        nextPassId++;
    }


    // Function to check whether a pass is expired or not
    function isPassExpired(address passHolder, uint256 passId) public view returns(bool){
        return passExpirationTime[passHolder][passId] < block.timestamp;
    }

}
