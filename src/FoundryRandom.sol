// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { BytesLib } from "../lib/solidity-bytes-utils/contracts/BytesLib.sol";
import { CramBit } from "../lib/CramBit/src/CramBit.sol";

import { FFICast } from "./FFICast.sol";

/**
 * @title FoundryRandom
 * @author Joe Jordan
 * @notice Generate reliably random numbers using Foundry's FFI cheat code.
 * @dev make sure that you have enabled `ffi = true` in your foundry.toml config file.
 */
contract FoundryRandom {
    FFICast private ffi = new FFICast();

    /// @notice generate a random uint between 0 and maxVal
    /// @param maxVal the maximum value of the random number you wish to generate.
    /// @return a random number that is less than or equal to maxVal
    function randomNumber(uint256 maxVal) public returns (uint256) {
        bytes32 _pk = ffi.generatePrivateKey();
        uint16 _maxBits = maxBits(maxVal);

        // return pk untouched if maxBits == 256, else get our desired number of bits
        bytes32 randomBytes = _maxBits == 256 ? _pk : CramBit.getLastNBits32(_pk, _maxBits);

        // convert random bytes extracted from pk to uint
        uint256 randomUint = uint256(randomBytes);

        if (randomUint > maxVal) {
            // if our random number is greater than maxVal,
            // subtract maxVal and use that number as the random value.
            return randomUint - maxVal;
        }

        return randomUint;
    }

    /// @notice generate a random uint between minVal and maxVal
    /// @param minVal the minimum value of the random number you wish to generate.
    /// @param maxVal the maximum value of the random number you wish to generate.
    /// @return a random number in the range provided.
    function randomNumber(uint256 minVal, uint256 maxVal) public returns (uint256) {
        require(maxVal >= minVal, "maxVal must be >= minVal");
        bytes32 _pk = ffi.generatePrivateKey();
        uint16 _maxBitsOfRange = maxBits(maxVal) - maxBits(minVal);

        // return pk untouched if maxBits == 256, else get our desired number of bits
        bytes32 randomBytes = _maxBitsOfRange == 256 ? _pk : CramBit.getLastNBits32(_pk, _maxBitsOfRange);

        // convert random bytes to uint and add back the minVal so that the random number falls in the desired range
        uint256 randomUint = uint256(randomBytes) + minVal;

        if (randomUint > maxVal) {
            // if our random number is greater than maxVal,
            // subtract maxVal and use that number as the random value.
            return randomUint - maxVal;
        }

        return randomUint;
    }

    /// @notice generate a random bytes32 value
    function randomBytes32() public returns (bytes32) {
        return ffi.generatePrivateKey();
    }

    /// @notice extract number from a bytes32 value
    /// @return value - a maximum random value; remainingBytes - bytes remaining after we shift out the used ones
    /// @dev useful in reusing generated private key for several smaller numbers
    /// @dev this function has no checks to ensure you have enough populated bits
    /// in the _pk argument to consider the maximum range desired. Proceed with care.
    function extractNumberFromBytes(
        uint256 maxVal,
        bytes32 _pk
    ) public pure returns (uint256 value, bytes32 remainingBytes) {
        uint16 _maxBits = maxBits(maxVal);

        // return pk untouched if maxBits == 256, else get our desired number of bits
        bytes32 randomBytes = _maxBits == 256 ? _pk : CramBit.getLastNBits32(_pk, _maxBits);

        // convert random bytes extracted from pk to uint
        uint256 randomUint = uint256(randomBytes);

        if (randomUint > maxVal) {
            // if our random number is greater than maxVal,
            // subtract maxVal and use that number as the random value.
            return (randomUint - maxVal, CramBit.bitRightShift32(_pk, _maxBits));
        }

        return (randomUint, CramBit.bitRightShift32(_pk, _maxBits));
    }

    /// @notice determine how many bits are required to fit the passed value
    function maxBits(uint256 value) public pure returns (uint16) {
        uint16 bitCount;
        while (value > 0) {
            ++bitCount;
            value = value >> 1;
        }
        return bitCount;
    }
}
