// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

contract Contract {
    /// @notice Encrtypts the data with key by xoring it, and decrypts by xoring once again.
    /// @dev MODIFIERS: public – can be called both externally and internally, pure – does not change state and is free to be externally
    /// @param data - data to encrypt/decrypt, passed as memory because we're mloading it
    /// @param key - key to encrypt/decrypt with, passed as calldata as we do not modify it, we just propagate it to encodePacked, 
    function encryptDecrypt(bytes memory data, bytes calldata key) public pure returns (bytes memory result) {
        // Store data length on stack for later use
        // NOTE: This is needed for using in the assembly block as data.length is not a local variable and we can't get it from there
        uint256 length = data.length;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Set result to free memory pointer
            // NOTE: According to Solidity Layout in Memory, 0x00-0x3f is scratch space and can be used only if a function
            // does not continue to do anything outside of the assembly block, as this space is reserved for Solidity
            // 0x40-0x5f (32 bytes) is the free memory pointer that we need to update everytime we write to the memory
            // 0x60-0x7f 0 slot and so on.
            result := mload(0x40)
            // Increase free memory pointer by 32 bytes as the return data is RLP (Recursive Length Prefix) encoded, 
            // We need to store the length of the return data which will lie in first 32 bytes
            // as the size of the data won't change – only content changes, the length of the result is the same as of the data
            // Thus we increase it to move the free memory pointer after we store the length
            mstore(0x40, add(add(result, length), 32))
            // Set length at the current result pointer
            mstore(result, length)
        }
        // Iterate over the data stepping by 32 bytes
        // NOTE: we step by 32 bytes because we decided to chunk the data by 32 bytes so we could write with simple mstore
        for (uint256 i = 0; i < length; i += 32) {
            // Generate hash of the key and offset
            // NOTE: abi.encodePacked(...) concatenates the dynamic types directly without padding, but the uint256 value is padded with zeroes from left
            // keccak256 is commonly used hashing function from SHA3 cryptographic algorithm family
            bytes32 hash = keccak256(abi.encodePacked(key, i));
            // NOTE: prepare the bytes32 variable for setting in assembly block
            bytes32 chunk;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // Read 32-bytes data chunk
                // NOTE: add 32 bytes beforehand so the first 32 bytes of data.length which has been written before is skipped
                chunk := mload(add(data, add(i, 32)))
            }
            // XOR the chunk with hash
            // NOTE: As the function name stands encryptDecrypt – we can encrypt the data with this key by xoring and decrypt by xoring once again - it's symmetric
            chunk ^= hash;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // Write 32-byte encrypted chunk
                // NOTE: we also add 32 bytes beforehand to skip the length of the result which we saved at the first assembly block
                mstore(add(result, add(i, 32)), chunk)
            }
        }
    }
}
