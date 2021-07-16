// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0; 

/**
 * @title PaymentChannel
 * @author td-bn
 * @dev An off chain claim to payment between parties
 */
contract PaymentChannel {
    address public owner;
    mapping(uint256 => bool) nonceUsed;
    
    constructor() payable {
        owner = msg.sender;
    }
    
    // Nonce uniqueness to prevent replay attacks
    modifier unusedNonce(uint256 nonce) {
        require(!nonceUsed[nonce]);
        _;
    }
    
    // Check for owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
        
    /**
     * @dev make a claim for a payment using a signature provided off-chain by owner
     * @param _amount: claimed amount
     * @param _nonce: unique number associated with payment to prevent replays
     * @param _signature: the signature of the owner authorizing the payment
     */
    function claimPayment(uint256 _amount, uint256 _nonce, bytes memory _signature) public unusedNonce(_nonce){
        nonceUsed[_nonce] = true;
        
        // Recreate the message that was signed by owner which is a hash of (payee, amount, nonce, contractAddress)
        bytes32 message = _recreateMessage(msg.sender, _amount, _nonce);
        
        // Make sure the signer and owner are the same
        address signer = _recoverSigner(message, _signature);
        require(signer == owner, "error verifying signature");
        
        //Authorize payment
        payable(msg.sender).transfer(_amount);
    }
    
    /**
     * @dev kill contract transferring the remaining funds to the owner
     */
    function kill() public onlyOwner {
        selfdestruct(payable(owner));
    }

    /**
     * @dev recreates the message that was signed by the owner
     * @param _payee: address authorized to receive payment 
     * @param _amount: authorized amount
     * @param _nonce: to prevent replays
     * @return the recreated message
     */
    function _recreateMessage(address _payee, uint256 _amount, uint256 _nonce) internal view returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(_payee, _nonce, _amount, this));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    
    /**
     * @dev recovers the address that was used to sign this message using ecrecover
     * @param _message: the message that was signed
     * @param _sign: the signature itself
     * @return address: the address that was used to sign the message
     */ 
    function _recoverSigner(bytes32 _message, bytes memory _sign) internal pure returns (address) {
        require(_sign.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            // First 32 bytes
            r := mload(add(_sign, 32))
            // Second 32 bytes
            s := mload(add(_sign, 64))
            // Final byte
            v := byte(0, mload(add(_sign, 96)))
        }
        
        return ecrecover(_message, v, r, s);
    }
}