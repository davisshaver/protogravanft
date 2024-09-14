// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

/// ============ External Imports ============

import "ds-test/test.sol";

/// ============ Internal Imports ============

import "../../LilHash.sol";

/* solhint-disable no-empty-blocks */
contract LilHashExample is LilHash {

}

/* solhint-enable no-empty-blocks */

abstract contract LilHashTest is DSTest {
    /// ============ Storage ============

    /// @dev LilHash contract
    LilHash internal hashtest;

    function setUp() public virtual {
        hashtest = new LilHashExample();
    }
}
