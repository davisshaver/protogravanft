// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

/// ============ External Imports ============

import {Test} from "forge-std/Test.sol";

/// ============ Internal Imports ============

import {LilHash} from "../../LilHash.sol";

/* solhint-disable no-empty-blocks */
contract LilHashExample is LilHash {}

/* solhint-enable no-empty-blocks */

abstract contract LilHashTest is Test {
    /// ============ Storage ============

    /// @dev LilHash contract
    LilHash internal hashtest;

    function setUp() public virtual {
        hashtest = new LilHashExample();
    }
}
