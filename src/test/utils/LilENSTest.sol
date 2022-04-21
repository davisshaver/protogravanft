// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.13;

/// ============ External Imports ============

import "ds-test/test.sol";

/// ============ Internal Imports ============

import "../../LilENS.sol";

/* solhint-disable no-empty-blocks */
contract LilENSExample is LilENS {

}

/* solhint-enable no-empty-blocks */

abstract contract LilENSTest is DSTest {
    /// ============ Storage ============

    /// @dev LilENS contract
    LilENS internal enstest;

    function setUp() public virtual {
        enstest = new LilENSExample();
    }
}
