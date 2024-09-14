// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.27;

/// ============ External Imports ============

import {Test} from "forge-std/Test.sol";

/// ============ Internal Imports ============

import {LilENS} from "../../LilENS.sol";

/* solhint-disable no-empty-blocks */
contract LilENSExample is LilENS {}

/* solhint-enable no-empty-blocks */

abstract contract LilENSTest is Test {
    /// ============ Storage ============

    /// @dev LilENS contract
    LilENS internal enstest;

    function setUp() public virtual {
        enstest = new LilENSExample();
    }
}
