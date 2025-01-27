# Remix Default Workspace

The **Remix Default Workspace** is your starting point when:
1. Remix is loaded for the first time.
2. A new workspace is created using the 'Default' template.
3. No files exist in the File Explorer.

This workspace provides a well-organized structure to help you explore, write, and deploy Solidity smart contracts. It contains three key directories:

## Workspace Structure

### 1. **Contracts**
- This directory includes three smart contracts, each with increasing levels of complexity.
- Use these examples to learn and build your own smart contracts.

### 2. **Scripts**
- Four TypeScript files are provided to deploy contracts using `web3.js` and `ethers.js`.
- These scripts are designed for deploying the **Storage** contract but can be easily adapted for other contracts (see instructions below).

### 3. **Tests**
- Includes unit tests for two sample contracts:
  - A Solidity test file for the **Ballot** contract.
  - A JavaScript test file for the **Storage** contract.

---

## Deploying Contracts with Scripts

The `scripts` folder contains deployment scripts (`deploy_with_ethers.ts` and `deploy_with_web3.ts`) for the **Storage** contract. Here's how to adapt them for other contracts:

1. Update the contract name from `Storage` to your desired contract.
2. Provide the required constructor arguments in the scripts.

### Running a Script:
1. **Compile** the Solidity file first.
2. Right-click the script in the File Explorer and select **Run**.
3. The output will appear in the Remix terminal.

---

## Testing Contracts

The `tests` folder includes:
- Mocha-Chai unit tests for the **Storage** contract.
- A Solidity test for the **Ballot** contract.

Use these tests as templates to validate your own contracts.

---

## Notes on Module Support

- **Supported Modules**: Remix IDE currently supports the following modules: `ethers`, `web3`, `swarmgw`, `chai`, `multihashes`, `remix`, and `hardhat` (for the Hardhat `ethers` object/plugin).
- **Unsupported Modules**: Using unsupported modules will throw an error:  
  *`<module_name> module require is not supported by Remix IDE`.*

---

## Use This Repository in Remix IDE (Web)

To integrate this repository with Remix IDE, follow these steps:

1. Install Remixd globally:
   ```bash
   npm install -g @remix-project/remixd
2. Run Remixd to connect your local files to the web-based Remix IDE:
   ```bash
   remixd -s ./remix -u https://remix.ethereum.org

Now you can interact with this workspace seamlessly in Remix IDE! 🚀
