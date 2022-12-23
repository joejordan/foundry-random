// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { PRBTest } from "@prb/test/PRBTest.sol";

import { BytesLib } from "../lib/solidity-bytes-utils/contracts/BytesLib.sol";
import { CramBit } from "../lib/CramBit/src/CramBit.sol";

/**
 * @title FFICast
 * @author Joe Jordan
 * @notice Executes `cast wallet new` and parses the output to retrieve the randomly generated private key
 * @dev make sure that you have enabled `ffi = true` in your foundry.toml config file.
 */
contract FFICast is PRBTest {
    /// @notice return a random bytes32 value as provided by `cast wallet new`
    function generatePrivateKey() public returns (bytes32) {
        bytes memory privKeyData;

        string[] memory inputs = new string[](3);
        inputs[0] = "cast";
        inputs[1] = "wallet";
        inputs[2] = "new";

        // execute `cast wallet new` and return the output to res
        bytes memory res = vm.ffi(inputs);

        // cast private key is returned in last 64 bytes at the end of res
        privKeyData = BytesLib.slice(res, res.length - 64, 64);

        // convert the weird ASCII-byte values returned by cast call into a valid bytes32 value
        return asciiToByte(privKeyData);
    }

    /// @dev VM::ffi([cast, wallet, new]) returns an ASCII-value-as-a-byte array that we need to
    /// convert from before we can deduce the private key that cast generated.
    function asciiToByte(bytes memory byteArray) internal pure returns (bytes32) {
        bytes memory converted;
        bytes memory convertedCompact;

        // first pass: get all ASCII representations in the byte array converted to their actual byte value
        // note: value looks like the following after first pass:
        // 0x070a0c020c0f0304000f050b0506070b080d0408090003040409...
        for (uint256 i = 0; i < byteArray.length; i++) {
            uint8 char = uint8(byteArray[i]);
            converted = BytesLib.concat(converted, charToByte(char));
        }

        // second pass: merge back-to-back bytes into a single byte
        // note: value is formatted into a proper private key format, i.e.
        // 0x7ac2cf340f5b567b8d48903449ef3b3f46236866a215be2891eecd7a9169fcaf
        for (uint256 i = 0; i < converted.length - 1; i++) {
            bytes1 mergedByte = mergeBytes(converted[i], converted[i + 1]);
            convertedCompact = bytes.concat(convertedCompact, mergedByte);
            // skip the next entry since we included i+1 in the mergeBytes call above
            i++;
        }

        // convert dynamic bytes array to bytes32
        bytes32 pk = BytesLib.toBytes32(convertedCompact, 0);

        return pk;
    }

    /// @notice Using the CramBit library, we can easily merge
    /// what are essentially half-bytes into a single full byte.
    function mergeBytes(bytes1 byteVal1, bytes1 byteVal2) internal pure returns (bytes1) {
        CramBit.PackBytes1[] memory packBytes = new CramBit.PackBytes1[](2);

        packBytes[0] = CramBit.PackBytes1({ maxBits: 4, data: byteVal1 });
        packBytes[1] = CramBit.PackBytes1({ maxBits: 4, data: byteVal2 });

        return CramBit.pack(packBytes);
    }

    /// @dev 0123456789abcdef = 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102
    function charToByte(uint8 charVal) internal pure returns (bytes memory) {
        // return bytes(0->9) value
        if (charVal > 47 && charVal < 58) {
            return abi.encodePacked(bytes1(charVal - 48));
        }
        // return bytes(a->f) value
        if (charVal > 96 && charVal < 103) {
            return abi.encodePacked(bytes1(charVal - 87));
        }

        /// @notice revert if we've detected a non-hex character
        /// @dev if this happens, it's possible that `cast wallet new` has changed its private key text output.
        revert("NON_HEX_CHARACTER_FOUND");
    }
}
