
export const contractAddress = "0x18c40dd3e5bB73232AB6C7F294DedB95Ed1D682D";

export const contractABI = [
    "function owner() view returns (address)",
    "function getBalance() view returns (uint256)",
    "function nextMilestoneId() view returns (uint256)",
    "function milestones(uint256) view returns (string description, uint256 totalAmount, address vendor, string imageProofHash, bool isInitialPaid, bool isFinalPaid, bool proofSubmitted)",
    "function vendorRegistry(address) view returns (string name, string category, bool isVerified)",
    "function registerVendor(address _vAddr, string _name, string _cat)",
    "function addMilestone(string _description, uint256 _amount, address _vendor)",
    "function releaseInitial50Percent(uint256 _id)",
    "function releaseFinal50Percent(uint256 _id)",
    "function submitProof(uint256 _id, string _ipfsHash)",
    "function receive() external payable"
];
