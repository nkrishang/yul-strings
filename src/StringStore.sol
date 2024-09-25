// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract StringStore {
    string private name;

    function getName() external view returns (string memory) {
        assembly {
            // Load free memory pointer.
            let ptr := mload(0x40)

            // Load value at name.storage_slot
            let s := sload(name.slot)

            // For strings of len < 32 bytes, Solidity stores (len * 2) in the final byte
            // of the value at name.storage_slot. So, the final bit will always be `0`.
            //
            // For strings of len >= 32 bits, Solidity stores ((len * 2) + 1) as the value at
            // name.storage_slot. So, the final bit will always be `1`.
            //
            // So, we fetch the final bit to check how long the output string is, which determines
            // where in storage to look for the output string.
            let b := shl(255, s)

            if eq(b, 0x00) {
                // Get string length stored in the final byte.
                let len := and(s, 0x00000000000000000000000000000000000000000000000000000000000000ff)

                // Store an abi encoded string in memory.
                // 1st word: offset
                mstore(ptr, 0x20)
                // 2nd word: string length
                mstore(add(ptr, 0x20), div(len, 2))
                // then: string data
                mstore(add(ptr, 0x40), s)

                // Update free memory pointer
                mstore(0x40, add(ptr, 0x60))

                // Return abi encoded string.
                return(ptr, 0x60)
            }

            // Copy the free memory pointer. We'll use it when returning
            let ptrCopy := ptr

            // Get storage slot of string data as keccak256(name.storage_slot)
            mstore(0x00, name.slot)
            let loc := keccak256(0x00, 0x20)

            // Store an abi encoded string in memory.
            // 1st word: offset
            mstore(ptr, 0x20)
            ptr := add(ptr, 0x20)

            // 2nd word: string length
            // For long strings, length is stored at name.storage_slot.
            let len := div(s, 2)
            mstore(ptr, len)
            ptr := add(ptr, 0x20)

            // Keep reading successive storage slots till string length is exhausted.
            for {} sgt(len, 0x00) { len := sub(len, 0x20) } {
                mstore(ptr, sload(loc))
                loc := add(loc, 1)
                ptr := add(ptr, 0x20)
            }

            // Update free memory pointer
            mstore(0x40, ptr)

            // Return abi encoded string.
            return(ptrCopy, sub(ptr, ptrCopy))
        }
    }

    function setName(string memory) external {
        assembly {
            // Get length of string.
            //
            // First 4 bytes are fn selector. The next 32 bytes are the offset
            // (which we can ignore in this case) where the string data starts.
            //
            // The next 32 bytes are the length of the string and the remaining
            // bytes are the string data.
            let len := calldataload(0x24)

            if lt(len, 0x20) {
                // Get the string data.
                let data := calldataload(0x44)

                // Store the string data, with (len*2) as its final byte.
                sstore(name.slot, or(data, mul(len, 2)))

                stop()
            }

            // Store (len*2) + 1 at name.storage_slot to indicate that
            // that the string len >= 32 bytes
            sstore(name.slot, add(mul(len, 2), 1))

            // Get storage slot of string data as keccak256(name.storage_slot)
            mstore(0x00, name.slot)
            let loc := keccak256(0x00, 0x20)
            let offset := 0x44

            // Keep storing string data in successive storage slots till string is exhausted.
            for {} sgt(len, 0x00) { len := sub(len, 0x20) } {
                sstore(loc, calldataload(offset))
                loc := add(loc, 1)
                offset := add(offset, 0x20)
            }

            stop()
        }
    }
}
