// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

import "src/Hyperpool.sol";

contract HyperpoolTest is TestEnvironment {
    Hyperpool pool;

    function setUp() public virtual override {
        super.setUp();

        pool = new Hyperpool(
            "Impact Pool",
            "iPOOL",
            startTime - 30 days,
            endTime + 30 days,
            address(certs)
        );

        certs.safeTransferFrom(self, address(pool), evalId, 1, "");
    }

    function testClaiming() public {
        certs.setApprovalForAll(address(pool), true);
        pool.claim(evalId, "Claiming Impact", self);

        assertEq(pool.balanceOf(self), 42 ether);
        assertEq(certs.balanceOf(self, evalId), 1);
        assertEq(certs.balanceOf(address(pool), claimId), 1);
    }

    function testReclaiming() public {
        certs.setApprovalForAll(address(pool), true);

        pool.claim(evalId, "Claiming Impact", self);
        pool.reclaim(evalId, "Reclaiming Impact", self);

        assertEq(pool.balanceOf(self), 0);
        assertEq(certs.balanceOf(address(pool), evalId), 1);
        assertEq(certs.balanceOf(self, claimId), 1);
    }
}
