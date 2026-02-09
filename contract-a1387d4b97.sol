// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract NGO {
    address public owner;
    bool public paused;

    struct Milestone {
        string description;
        uint256 amount;
        address payable vendor; // LINKED: The specific vendor for this task
        bool approved;
        bool paid;
    }

    struct Vendor {
        string name;
        string category; 
        bool isVerified;
    }

    Milestone[] public milestones;
    uint256 public nextMilestoneId; // Incremented for frontend visibility
    mapping(address => Vendor) public vendorRegistry;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _initialOwner) {
        require(_initialOwner != address(0), "Owner address cannot be zero");
        owner = _initialOwner;
    }

    receive() external payable {}

    // 1. REGISTER: Add vendor to the system first
    function registerVendor(address _vAddr, string memory _name, string memory _cat) public onlyOwner {
        vendorRegistry[_vAddr] = Vendor(_name, _cat, true);
    }

    // 2. CREATE: Assign a verified vendor to a specific task
    function addMilestone(string memory _description, uint256 _amount, address payable _vendor) public onlyOwner {
        require(vendorRegistry[_vendor].isVerified, "Vendor is not verified in our registry");
        milestones.push(Milestone(_description, _amount, _vendor, false, false));
        nextMilestoneId++; // Now the frontend can see the new count
    }

    function approveMilestone(uint256 _id) public onlyOwner {
        require(_id < milestones.length, "Invalid milestone ID");
        milestones[_id].approved = true;
    }

    // 3. RELEASE: Sends money ONLY to the vendor pre-assigned in step 2
    function releaseMilestone(uint256 _id) public onlyOwner {
        Milestone storage m = milestones[_id];
        require(m.approved, "Milestone not yet approved");
        require(!m.paid, "Milestone already paid");
        require(address(this).balance >= m.amount, "Insufficient balance");

        m.paid = true;
        // Money is sent to m.vendor, not a manual address input
        (bool success, ) = m.vendor.call{value: m.amount}("");
        require(success, "Transfer failed.");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
