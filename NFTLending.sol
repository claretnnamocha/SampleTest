// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTLending is Ownable2Step, ReentrancyGuard, IERC721Receiver {
    struct Loan {
        address borrower;
        uint256 amount;
        address nftContract;
        uint256 tokenId;
        bool repaid;
        bool disbursed;
        bool created;
    }

    mapping(uint256 => Loan) public loans;
    uint256 public loanCounter = 1;

    constructor() Ownable(msg.sender) {}

    event LoanCreated(
        address borrower,
        uint256 amount,
        address nftContract,
        uint256 tokenId,
        uint256 loanId
    );

    event LoanRepaid(uint256 loanId);

    event LoanDisbursed(uint256 loanId);

    function createLoan(
        address nftContract,
        uint256 tokenId,
        uint256 loanAmount
    ) external nonReentrant {
        bytes memory data = abi.encode(loanCounter);

        loans[loanCounter] = Loan({
            borrower: msg.sender,
            amount: loanAmount,
            nftContract: nftContract,
            tokenId: tokenId,
            repaid: false,
            disbursed: false,
            created: true
        });

        // Transfer the NFT to the contract as collateral
        IERC721(nftContract).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            data
        );

        emit LoanCreated(
            msg.sender,
            loanAmount,
            nftContract,
            tokenId,
            loanCounter
        );
        loanCounter++;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        uint256 loanId = abi.decode(data, (uint256));

        require(address(this) == operator, "Not Initiated");

        Loan storage loan = loans[loanId];

        require(loan.created == true, "Not created");
        require(loan.borrower == from, "Not borrower");
        require(loan.tokenId == tokenId, "Not borrowed");
        require(loan.disbursed == false, "Loan already disbursed");

        loan.disbursed = true;
        emit LoanDisbursed(loanId);

        return this.onERC721Received.selector;
    }

    function repayLoan(uint256 loanId) external payable nonReentrant {
        Loan storage loan = loans[loanId];
        require(loan.borrower == msg.sender, "Not borrower");
        require(loan.amount == msg.value, "Incorrect repayment amount");
        require(!loan.repaid, "Loan already repaid");

        loan.repaid = true;

        // Return the NFT to the borrower
        IERC721(loan.nftContract).safeTransferFrom(
            address(this),
            msg.sender,
            loan.tokenId
        );

        emit LoanRepaid(loanId);
    }
}
