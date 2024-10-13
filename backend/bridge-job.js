require("dotenv").config();
const { ethers } = require("ethers");

// Setup RPC providers
const providerChainA = new ethers.providers.JsonRpcProvider(
  process.env.RPC_URL_CHAIN_A
);
const providerChainB = new ethers.providers.JsonRpcProvider(
  process.env.RPC_URL_CHAIN_B
);

// Setup wallet (Relayer) with private key
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, providerChainB);

// Bridge contract ABI
const bridgeAbi = [
  "event TokenLocked(address indexed user, address token, uint256 amount, uint256 chainId)",
  "function confirmUnlock(address token, uint256 amount, address user, uint256 chainId) external",
];

// Initialize Bridge contract instances
const bridgeContractChainA = new ethers.Contract(
  process.env.BRIDGE_CONTRACT_ADDRESS_CHAIN_A,
  bridgeAbi,
  providerChainA
);
const bridgeContractChainB = new ethers.Contract(
  process.env.BRIDGE_CONTRACT_ADDRESS_CHAIN_B,
  bridgeAbi,
  wallet
);

// Listen to TokenLocked events on Chain A
bridgeContractChainA.on("TokenLocked", async (user, token, amount, chainId) => {
  console.log(`Token Locked on Chain A: ${amount} tokens by ${user}`);

  // Check if the destination chain is Chain B
  if (chainId === (await providerChainB.getNetwork().chainId)) {
    try {
      // Call confirmUnlock on Chain B
      const tx = await bridgeContractChainB.confirmUnlock(
        token,
        amount,
        user,
        chainId
      );
      console.log(`Unlock confirmed on Chain B, tx hash: ${tx.hash}`);
    } catch (error) {
      console.error(`Error confirming unlock: ${error.message}`);
    }
  }
});
