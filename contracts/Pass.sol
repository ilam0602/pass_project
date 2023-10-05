// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Pass is ERC1155, Ownable {
    uint256 public nextPassId = 0;
    uint256 public passDuration = 365 days;

    // Mapping from pass ID to its price
    mapping(uint256 => uint256) public passPrice;

    // Mapping from pass ID to its sale start time
    mapping(uint256 => uint256) public passSaleStartTime;

    // Mapping from user address and pass ID to its expiration time
    mapping(address => mapping(uint256 => uint256)) public passExpirationTime;


    // Loan struct to represent an active loan
    struct Loan {
        address borrower;
        uint256 startTime;
        uint256 endTime;
        bool returned;
    }

    // Mapping to keep track of active loans (lender's address and passId to Loan details)
    mapping(address => mapping(uint256 => Loan)) public activeLoans;

    constructor() ERC1155("URI GOES HERE/{id}") {}

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


    function setPassPrice(uint256 passId, uint256 _price) external onlyOwner {
        passPrice[passId] = _price;
    }

    // Users can buy a pass by sending ether
    function purchasePass(uint256 passId) external payable {
        require(msg.value == passPrice[passId], "Passes: Incorrect Ether sent");
        require(balanceOf(address(this), passId) > 0, "Passes: Out of stock");
        require(block.timestamp >= passSaleStartTime[passId], "Passes: Sale has not started for this pass");

        // Transfer the NFT to the purchaser
        safeTransferFrom(address(this), msg.sender, passId, 1, "");

        // Set the expiration time for the pass for this specific user
        passExpirationTime[msg.sender][passId] = block.timestamp + passDuration;

        // Transfer the payment to the owner
        payable(owner()).transfer(msg.value);
    }

    // Users can reactivate an expired pass
    function reactivatePass(uint256 passId) external payable {
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
    function mintPass(uint256 amount, uint256 saleStartTime, uint256 _price, bytes memory data) external onlyOwner {
        require(saleStartTime >= block.timestamp, "Passes: Sale start time should be in the future");

        // Set the price for the newly minted pass
        passPrice[nextPassId] = _price;

        _mint(address(this), nextPassId, amount, data);  // Minting to the contract itself
        passSaleStartTime[nextPassId] = saleStartTime;
        nextPassId++;
    }


    // Function to allow lending of a pass
    function lendPass(address borrower, uint256 passId, uint256 duration) external {
        require(balanceOf(msg.sender, passId) > 0, "You don't own this pass");
        require(activeLoans[msg.sender][passId].borrower == address(0), "This pass is already lent out");

        // Transfer pass to borrower
        safeTransferFrom(msg.sender, borrower, passId, 1, "");

        // Record the loan details
        activeLoans[msg.sender][passId] = Loan({
            borrower: borrower,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            returned: false
        });
    }

    // Function to end the loan and return the pass
    function endLoan(uint256 passId) external {
        Loan storage loan = activeLoans[msg.sender][passId];
        
        require(loan.borrower != address(0), "No active loan found for this pass");
        require(!loan.returned, "This pass has already been returned");
        require(loan.borrower == msg.sender || block.timestamp >= loan.endTime, "Only the borrower can return before the end time");
        
        // Transfer pass back to owner from borrower
        safeTransferFrom(loan.borrower, msg.sender, passId, 1, "");
        
        // Delete the loan data
        delete activeLoans[msg.sender][passId];
    }

}
