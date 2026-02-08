// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract NGO {
    address public owner;
    bool public paused;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is currently paused");
        _;
    }

    constructor(address _initialOwner) {
    
        require(_initialOwner != address(0), "Owner address cannot be zero");
        owner = _initialOwner;
        paused = false;
    }


    receive() external payable {}
    fallback() external payable {}

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }


    function donate() public payable whenNotPaused {
        require(msg.value > 0, "Donation must be greater than 0");
    }

    function releaseFunds(address payable _to, uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed.");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}