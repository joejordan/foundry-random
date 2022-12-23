// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";

import { BytesLib } from "solidity-bytes-utils/BytesLib.sol";
import { CramBit } from "../lib/CramBit/src/CramBit.sol";

import { FFICast } from "../src/FFICast.sol";

/// @notice basic functionality test of our FFICast project
contract FFICastTest is PRBTest {
    FFICast public ffi;

    function setUp() public {
        ffi = new FFICast();
    }

    /// @notice assert that the FFI private key generator returns a bytes32 > 0
    function testGetRandomPrivateKey() public {
        bytes32 pk = ffi.generatePrivateKey();
        assertGt(uint256(pk), 0);
    }

    /// @notice output 10 randomly generated private keys
    function testConsole10PrivateKeys() public {
        for (uint256 i = 0; i < 10; i++) {
            console2.logBytes32(ffi.generatePrivateKey());
        }
    }
}
