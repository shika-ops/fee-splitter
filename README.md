# Fee Splitter Smart Contract

This Clarity smart contract implements a fee splitter that distributes STX payments proportionally to a predefined list of recipients. It allows the contract owner to initialize and update the recipient list, ensuring the total share percentages always sum to 100. The `split-payment` function automatically calculates and distributes the correct amount of STX to each recipient based on their configured share. Built with security and efficiency in mind, this contract provides a reliable solution for automated fee distribution on the Stacks blockchain.

## Features

* **Flexible Recipient Management:**  The contract owner can initialize and update the list of recipients and their respective shares.
* **Automatic Distribution:** The `split-payment` function automatically calculates and distributes the correct STX amount to each recipient.
* **Security:** Only the contract owner can modify the recipient list, preventing unauthorized changes.
* **Efficiency:** Uses `fold` for efficient iteration and distribution of funds.
* **Error Handling:** Includes error codes for invalid percentage sums and unauthorized access.

## How it Works

1. **Initialization:** The contract owner deploys the contract and initializes the recipient list using the `initialize-recipients` function.  This list consists of tuples, each containing a recipient's principal address and their share percentage. The total share must add up to 100.
2. **Splitting Payments:**  When a user calls the `split-payment` function, the contract retrieves the user's STX balance. It then iterates through the recipient list and transfers the appropriate proportion of STX to each recipient based on their share.

## Functions

### `initialize-recipients`

```clarity
(define-public (initialize-recipients (new-recipients (list 10 (tuple (address principal) (share uint)))))
