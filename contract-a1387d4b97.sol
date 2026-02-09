// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract NGO {
    address public owner;
    bool public paused;

    struct Milestone {
        string description;
        uint256 totalAmount;
        address payable vendor;
        string imageProofHash; 
        bool isInitialPaid;    // Track if first 50% is sent
        bool isFinalPaid;      // Track if remaining 50% is sent
    }

    struct Vendor {
        string name;
        string category; 
        bool isVerified;
    }

    Milestone[] public milestones;
    uint256 public nextMilestoneId;
    mapping(address => Vendor) public vendorRegistry;

    event InitialPaymentReleased(uint256 indexed id, address vendor, uint256 amount);
    event FinalPaymentReleased(uint256 indexed id, address vendor, uint256 amount);
    event ProofSubmitted(uint256 indexed id, string ipfsHash);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _initialOwner) {
        require(_initialOwner != address(0), "Owner address cannot be zero");
        owner = _initialOwner;
    }

    receive() external payable {}

    function registerVendor(address _vAddr, string memory _name, string memory _cat) public onlyOwner {
        vendorRegistry[_vAddr] = Vendor(_name, _cat, true);
    }

    function addMilestone(string memory _description, uint256 _amount, address payable _vendor) public onlyOwner {
        require(vendorRegistry[_vendor].isVerified, "Vendor not verified");
        milestones.push(Milestone({
            description: _description,
            totalAmount: _amount,
            vendor: _vendor,
            imageProofHash: "",
            isInitialPaid: false,
            isFinalPaid: false
        }));
        nextMilestoneId++; 
    }

    // --- NEW 50% LOGIC ---

    /**
     * @dev Step 1: Release first 50% to the vendor to start the work.
     */
    function releaseInitial50Percent(uint256 _id) public onlyOwner {
        Milestone storage m = milestones[_id];
        require(!m.isInitialPaid, "Initial payment already made");
        
        uint256 half = m.totalAmount / 2;
        require(address(this).balance >= half, "Insufficient contract balance");

        m.isInitialPaid = true;
        (bool success, ) = m.vendor.call{value: half}("");
        require(success, "Initial transfer failed");

        emit InitialPaymentReleased(_id, m.vendor, half);
    }

   
    function submitProof(uint256 _id, string memory _ipfsHash) public {
        Milestone storage m = milestones[_id];
        require(msg.sender == m.vendor, "Only the assigned vendor can submit proof");
        require(m.isInitialPaid, "Must receive initial payment first");
        
        m.imageProofHash = _ipfsHash;
        emit ProofSubmitted(_id, _ipfsHash);
    }

    function releaseFinal50Percent(uint256 _id) public onlyOwner {
        Milestone storage m = milestones[_id];
        require(m.isInitialPaid, "Initial payment not yet made");
        require(!m.isFinalPaid, "Final payment already made");
        require(bytes(m.imageProofHash).length > 0, "No proof submitted yet");

        // Use subtraction to handle odd numbers (e.g., if total is 11, half is 5, remaining is 6)
        uint256 remaining = m.totalAmount - (m.totalAmount / 2);
        require(address(this).balance >= remaining, "Insufficient balance");

        m.isFinalPaid = true;
        (bool success, ) = m.vendor.call{value: remaining}("");
        require(success, "Final transfer failed");

        emit FinalPaymentReleased(_id, m.vendor, remaining);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
