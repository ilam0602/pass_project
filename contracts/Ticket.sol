// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; 

contract Tickets is ERC1155, Ownable {
    uint256 public nextTicketId = 0;

    // Mapping from ticket ID to its price
    mapping(uint256 => uint256) public ticketPrices;

    // Mapping from ticket ID to its sale start time
    mapping(uint256 => uint256) public ticketSaleStartTime;

    constructor() ERC1155("URI GOES HERE/{id}") {}

    function setTicketPrice(uint256 ticketId, uint256 _price) external onlyOwner {
        require(ticketId < nextTicketId, "Tickets: Invalid ticket ID");
        ticketPrices[ticketId] = _price;
    }

    // Users can buy a ticket by sending ether
    function purchaseTicket(uint256 ticketId) external payable {
        require(balanceOf(address(this), ticketId) > 0, "Tickets: Out of stock");
        require(block.timestamp >= ticketSaleStartTime[ticketId], "Tickets: Sale has not started for this ticket");
        require(msg.value == ticketPrices[ticketId], "Tickets: Incorrect Ether sent");

        // Transfer the NFT to the purchaser
        safeTransferFrom(address(this), msg.sender, ticketId, 1, "");

        // Transfer the payment to the owner
        payable(owner()).transfer(msg.value);
    }

    // Owner can mint new tickets in advance, set a sale start time, and price
    function mintTicket(uint256 amount, uint256 _price, uint256 saleStartTime, bytes memory data) external onlyOwner {
        require(saleStartTime >= block.timestamp, "Tickets: Sale start time should be in the future");

        _mint(address(this), nextTicketId, amount, data);  // Minting to the contract itself
        ticketPrices[nextTicketId] = _price;
        ticketSaleStartTime[nextTicketId] = saleStartTime;
        nextTicketId++;
    }

    // ... other functions as needed
}
