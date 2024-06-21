# Additional Weird ERC20 Edge Cases

### Name: Transfer of Less Than Amount

Some tokens (e.g., cUSDCv3) include a special case in their transfer functions where if the amount is equal to `type(uint256).max`, only the user's balance is transferred. This behavior can cause issues with systems that transfer a user-supplied amount to their contract and then credit the user with the same value in storage (e.g., Vault-type systems) without verifying the actual transferred amount.

### Name: Code Injection Via Token Name

Some malicious tokens have been observed to include malicious JavaScript in their name attribute. This allows attackers to extract private keys from users who interact with these tokens via vulnerable frontends. This exploit has been used to target EtherDelta users in the wild.

### Name: Flash Mintable Tokens

Some tokens (e.g., DAI) allow for "flash minting," which enables tokens to be minted for the duration of a single transaction, provided they are returned to the token contract by the end of the transaction. This is similar to a flash loan but does not require the tokens to exist before the transaction begins. A token that can be flash minted could potentially have a total supply of `max uint256`. 

