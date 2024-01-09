// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPreviousCollection {
    function balanceOf(address owner) external view returns (uint256);
}

contract Pass is ERC1155, Ownable {
    uint256 public nextPassId = 0;
    uint256 public priceInc = .0005 ether;

    // Mapping from pass ID to its price
    mapping(uint256 => uint256) public passPrice;

    // Mapping from pass ID to its sale start time
    mapping(uint256 => uint256) public passSaleStartTime;

    address public previousCollectionAddress;
    address public devWallet;
    address public ownerWallet;



    constructor() ERC1155("https://ipfs.io/ipfs/QmPDQhkcyobcuf7DwTobAiqf84W2uGQ1rregKSrXX5s3Cw/{id}.json") {}

    function setPassPrice(uint256 passId, uint256 _price) public onlyOwner {
        passPrice[passId] = _price;
    }

    function setPreviousCollectionAddress(address _previousCollectionAddress) external onlyOwner {
        previousCollectionAddress = _previousCollectionAddress;
    }
    function setDevWallet(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }
    function setOwnerWallet(address _ownerWallet) external onlyOwner {
        ownerWallet = _ownerWallet;
    }

    function getOwnerWallet() public view returns (address) {
        return ownerWallet;
    }
    function getDevWallet() public view returns (address) {
        return devWallet;
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
        require(balanceOf(owner(), passId) > qty, "Passes: Out of stock");
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


        // Transfer the payment to the owner
        uint256 devShare = (msg.value * 8)/ 100;
        payable(getOwnerWallet()).transfer(msg.value - devShare);
        payable(getDevWallet()).transfer(devShare);

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



}
