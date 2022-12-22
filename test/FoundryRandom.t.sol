// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";

import { BytesLib } from "solidity-bytes-utils/BytesLib.sol";
import { CramBit } from "crambit/CramBit.sol";

import { FoundryRandom } from "src/FoundryRandom.sol";

/// @notice tests of our Foundry random number generators.
contract FoundryRandomTest is PRBTest {
    FoundryRandom public foundryRandom;

    function setUp() public {
        foundryRandom = new FoundryRandom();
    }

    /// @notice test the random number generator so that it returns values within the users' desired range
    function testRandomNumber() public {
        uint256 randomNum;

        randomNum = foundryRandom.randomNumber(type(uint8).max);
        assertLte(randomNum, type(uint8).max);

        randomNum = foundryRandom.randomNumber(type(uint64).max);
        assertLte(randomNum, type(uint64).max);

        randomNum = foundryRandom.randomNumber(type(uint248).max);
        assertLte(randomNum, type(uint248).max);

        randomNum = foundryRandom.randomNumber(type(uint256).max);
        assertLte(randomNum, type(uint256).max);

        randomNum = foundryRandom.randomNumber(0);
        assertEq(randomNum, 0);

        randomNum = foundryRandom.randomNumber(1);
        assertLte(randomNum, 1);

        randomNum = foundryRandom.randomNumber(10);
        assertLte(randomNum, 10);

        randomNum = foundryRandom.randomNumber(123456789);
        assertLte(randomNum, 123456789);
    }

    /// @notice fuzz test the random number generator
    /// @dev ensure you have a decent number of fuzz rounds enabled in your foundry.toml file
    /// ex: fuzz = { runs = 256 }
    function testRandomNumberFuzz(uint256 maxVal) public {
        uint256 randomNum;

        randomNum = foundryRandom.randomNumber(maxVal);
        assertLte(randomNum, maxVal);
    }

    /// @notice test the random number generator so that it returns values within the users' desired range
    function testRandomNumberMinMax() public {
        uint256 randomNum;

        randomNum = foundryRandom.randomNumber(type(uint8).max, type(uint16).max);
        assertGte(randomNum, type(uint8).max);
        assertLte(randomNum, type(uint16).max);

        randomNum = foundryRandom.randomNumber(type(uint64).max, type(uint128).max);
        assertGte(randomNum, type(uint64).max);
        assertLte(randomNum, type(uint128).max);

        randomNum = foundryRandom.randomNumber(type(uint248).max, type(uint256).max);
        assertGte(randomNum, type(uint248).max);
        assertLte(randomNum, type(uint256).max);

        randomNum = foundryRandom.randomNumber(0, type(uint256).max);
        assertGte(randomNum, 0);
        assertLte(randomNum, type(uint256).max);

        randomNum = foundryRandom.randomNumber(0, 0);
        assertEq(randomNum, 0);

        randomNum = foundryRandom.randomNumber(1, 1);
        assertEq(randomNum, 1);

        randomNum = foundryRandom.randomNumber(0, 1);
        assert(randomNum == 0 || randomNum == 1);

        randomNum = foundryRandom.randomNumber(1, 2);
        assert(randomNum == 1 || randomNum == 2);

        randomNum = foundryRandom.randomNumber(123456789, 987654321);
        assertGte(randomNum, 123456789);
        assertLte(randomNum, 987654321);
    }

    /// @notice fuzz test the random number generator min max
    /// @dev ensure you have a decent number of fuzz rounds enabled in your foundry.toml file
    /// ex: fuzz = { runs = 256 }
    function testRandomNumberMinMaxFuzz(uint256 minVal, uint256 maxVal) public {
        vm.assume(maxVal >= minVal);
        uint256 randomNum;

        randomNum = foundryRandom.randomNumber(minVal, maxVal);
        assertGte(randomNum, minVal);
        assertLte(randomNum, maxVal);
    }

    /// @notice example on reusing a single random bytes32 multiple times for a series of smaller random uint ranges
    function testRandomReuse() public {
        uint256 randomUint;
        // generate a single random bytes32 value
        bytes32 randomBytes32 = foundryRandom.randomBytes32();
        bytes32 remainingBytes32 = randomBytes32;

        // reuse it multiple times
        (randomUint, remainingBytes32) = foundryRandom.extractNumberFromBytes(10, randomBytes32);
        console2.log("Random Uint (Max 10) = ", randomUint);
        console2.log("Remaining Bytes:");
        console2.logBytes32(remainingBytes32);

        (randomUint, remainingBytes32) = foundryRandom.extractNumberFromBytes(100, remainingBytes32);
        console2.log("Random Uint (Max 100) = ", randomUint);
        console2.log("Remaining Bytes:");
        console2.logBytes32(remainingBytes32);

        (randomUint, remainingBytes32) = foundryRandom.extractNumberFromBytes(1000, remainingBytes32);
        console2.log("Random Uint (Max 1000) = ", randomUint);
        console2.log("Remaining Bytes:");
        console2.logBytes32(remainingBytes32);

        (randomUint, remainingBytes32) = foundryRandom.extractNumberFromBytes(100_000, remainingBytes32);
        console2.log("Random Uint (Max 100_000) = ", randomUint);
        console2.log("Remaining Bytes:");
        console2.logBytes32(remainingBytes32);

        (randomUint, remainingBytes32) = foundryRandom.extractNumberFromBytes(100_000_000, remainingBytes32);
        console2.log("Random Uint (Max 100_000_000) = ", randomUint);
        console2.log("Remaining Bytes:");
        console2.logBytes32(remainingBytes32);

        (randomUint, remainingBytes32) = foundryRandom.extractNumberFromBytes(100_000_000_000_000, remainingBytes32);
        console2.log("Random Uint (Max 100_000_000_000_000) = ", randomUint);
        console2.log("Remaining Bytes:");
        console2.logBytes32(remainingBytes32);

        (randomUint, remainingBytes32) = foundryRandom.extractNumberFromBytes(
            100_000_000_000_000_000_000_000,
            remainingBytes32
        );
        console2.log("Random Uint (Max 100_000_000_000_000_000_000_000) = ", randomUint);
        console2.log("Remaining Bytes:");
        console2.logBytes32(remainingBytes32);
    }
}
