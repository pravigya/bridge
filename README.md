# Crypto Bridge

## Overview

**Crypto Bridge** is a full-stack decentralized application (dApp) that enables users to transfer tokens across two blockchain networks. The system consists of:
- **Smart Contracts** to lock and unlock tokens on different chains.
- A **Backend Relayer Service** that listens for token lock events and relays them across chains.
- A **Frontend dApp** built with Next.js and TailwindCSS for user interaction.

The bridge operates seamlessly between two blockchain networks by utilizing smart contracts, relayers, and secure multi-signature (multi-sig) validation.

---

## Table of Contents

1. [Technologies Used](#technologies-used)
2. [Architecture Overview](#architecture-overview)
3. [Smart Contracts](#smart-contracts)
4. [Backend Service](#backend-service)
5. [Frontend dApp](#frontend-dapp)

---

## Technologies Used

- **Solidity** for smart contract development.
- **Node.js** for the backend relayer service.
- **Ethers.js** for blockchain interaction.
- **Next.js** and **TailwindCSS** for the frontend dApp.
- **Azure** or **AWS** for backend deployment.
- **MetaMask** for wallet integration.

---

## Architecture Overview

The architecture consists of three primary components:

1. **Smart Contracts**: Deployed on two blockchain networks, they facilitate the locking and unlocking of tokens.
2. **Backend Relayer Service**: A Node.js service that listens for token lock events on Chain A and triggers the unlocking of tokens on Chain B.
3. **Frontend dApp**: A user interface where users can lock tokens and track the status of their transfers between chains.

---

## Smart Contracts

The smart contracts handle:
- **Locking Tokens**: On Chain A, users lock their tokens in the contract.
- **Unlocking Tokens**: On Chain B, the tokens are unlocked after the backend relayer service verifies the lock event.
- **Security**: Uses multi-sig wallets and other validation mechanisms to ensure only authorized relayers can initiate unlocks.

**Contract Functions:**
- `lockTokens(token, amount, chainId)`: Locks tokens on the originating chain.
- `confirmUnlock(token, amount, user, chainId)`: Unlocks tokens on the destination chain after verification.

---

## Backend Service

The backend relayer service:
1. **Listens for Events**: Monitors `TokenLocked` events on Chain A.
2. **Relays Transactions**: Upon detecting a lock event, it triggers the corresponding `confirmUnlock` transaction on Chain B.
3. **Security**: Uses environment variables to securely manage private keys.

**Technologies**:
- **Ethers.js** for interacting with smart contracts.
- **Express.js** (optional) if additional API features are needed.
- **Dotenv** for environment variable management.

---

## Frontend dApp

The frontend dApp allows users to:
- Lock tokens on Chain A using MetaMask.
- Monitor the status of the cross-chain transfer.
- View transaction history (optional).

**Technologies**:
- **Next.js** for server-side rendering and routing.
- **TailwindCSS** for styling.
- **Ethers.js** for blockchain interaction and MetaMask integration.


