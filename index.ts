import {
  BigNumberish,
  BrowserProvider,
  Contract,
  InfuraProvider,
  Wallet,
} from "ethers";

// Connect to Infura via js
const INFURA_PROJECT_ID = "your_infura_project_id";
const NETWORK = "your_evm_network";
const PRIVATE_KEY = "your_private_key";

const provider = new InfuraProvider(NETWORK, INFURA_PROJECT_ID);

// Smart contract address and ABI
const contractAddress = "your_contract_address"; // Deployed contract address
const contractABI = [
  // The minimal ABI needed for interacting with the contract
  "function createLoan(address nftContract, uint256 tokenId, uint256 loanAmount) external",
  "function repayLoan(uint256 loanId) external payable",
  "function loans(uint256) view returns (address, uint256, address, uint256, bool)",
];

// Connect the user’s wallet with MetaMask
export const connectWallet = async () => {
  try {
    if (window && typeof window.ethereum !== "undefined") {
      const accounts = window.ethereum.request({
        method: "eth_requestAccounts",
      });
      console.log("Connected:", accounts[0]);
    }
  } catch (error) {
    console.error("Error connecting to MetaMask:", error);
  }
};

// Interact with the smart contract using MetaMask
export const createLoan = async (
  nftContract: string,
  tokenId: number,
  loanAmount: BigNumberish
) => {
  try {
    if (window && typeof window.ethereum !== "undefined") {
      const provider = new BrowserProvider(window.ethereum);

      await provider.send("eth_requestAccounts", []);

      // Get signer
      const signer = await provider.getSigner();
      const lendingContract = new Contract(
        contractAddress,
        contractABI,
        signer
      );

      // Create a loan
      const tx = await lendingContract.createLoan(
        nftContract,
        tokenId,
        loanAmount
      );
      await tx.wait();
      console.log("Loan created, transaction hash:", tx.hash);
    }
  } catch (error) {
    console.error("Error connecting to MetaMask:", error);
  }
};

// Interact with the smart contract with Infura
export const repayLoan = async (loanId: string, amount: string) => {
  try {
    const signer = new Wallet(PRIVATE_KEY, provider);
    const contract = new Contract(contractAddress, contractABI, signer);

    await contract.repayLoan(loanId);
    console.log("Loan repaid");
  } catch (error) {
    console.error("Error repaying loan:", error);
  }
};
