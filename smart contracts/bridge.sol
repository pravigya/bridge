// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CryptoBridge {
    address public admin;
    uint256 public bridgeFee; // Fee as a percentage (e.g., 100 = 1%)
    mapping(address => bool) public relayers; // List of trusted relayers

    // Multi-sig data
    uint256 public requiredSignatures;
    mapping(bytes32 => mapping(address => bool)) public confirmations; // Confirmation of unlocks by relayers
    mapping(bytes32 => bool) public executedUnlocks; // To prevent double spending

    // Events
    event TokenLocked(address indexed user, address token, uint256 amount, uint256 chainId);
    event TokenUnlocked(address indexed user, address token, uint256 amount, uint256 chainId);
    event RelayerAdded(address relayer);
    event RelayerRemoved(address relayer);

    // Constructor
    constructor(uint256 _bridgeFee, uint256 _requiredSignatures) {
        admin = msg.sender;
        bridgeFee = _bridgeFee;
        requiredSignatures = _requiredSignatures;
    }

    // Lock tokens on Chain A
    function lockTokens(address token, uint256 amount, uint256 chainId) external {
        uint256 feeAmount = (amount * bridgeFee) / 10000; // Fee calculation
        uint256 finalAmount = amount - feeAmount;

        // Transfer tokens to contract
        IERC20(token).transferFrom(msg.sender, address(this), finalAmount);
        
        emit TokenLocked(msg.sender, token, finalAmount, chainId);
    }

    // Relayer confirms unlock on Chain B
    function confirmUnlock(address token, uint256 amount, address user, uint256 chainId) external onlyRelayer {
        bytes32 txHash = getTxHash(token, amount, user, chainId);
        confirmations[txHash][msg.sender] = true;

        if (getConfirmations(txHash) >= requiredSignatures && !executedUnlocks[txHash]) {
            executedUnlocks[txHash] = true;
            unlockTokens(token, amount, user);
        }
    }

    // Internal: Unlock tokens after multi-sig confirmation
    function unlockTokens(address token, uint256 amount, address user) internal {
        IERC20(token).transfer(user, amount);
        emit TokenUnlocked(user, token, amount, block.chainid);
    }

    // Add a trusted relayer
    function addRelayer(address _relayer) external onlyAdmin {
        relayers[_relayer] = true;
        emit RelayerAdded(_relayer);
    }

    // Remove a relayer
    function removeRelayer(address _relayer) external onlyAdmin {
        relayers[_relayer] = false;
        emit RelayerRemoved(_relayer);
    }

    // Admin: Update bridge fee
    function updateBridgeFee(uint256 _newFee) external onlyAdmin {
        bridgeFee = _newFee;
    }

    // Helper: Get transaction hash for confirmation
    function getTxHash(address token, uint256 amount, address user, uint256 chainId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(token, amount, user, chainId));
    }

    // Helper: Get the number of confirmations for a tx hash
    function getConfirmations(bytes32 txHash) public view returns (uint256 count) {
        for (uint256 i = 0; i < requiredSignatures; i++) {
            if (confirmations[txHash][msg.sender]) {
                count++;
            }
        }
    }

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyRelayer() {
        require(relayers[msg.sender], "Only relayers can call this function");
        _;
    }
}

// Interface for token interactions
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
