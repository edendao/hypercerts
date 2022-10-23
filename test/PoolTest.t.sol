// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

import "src/Pool.sol";

contract PoolTest is TestEnvironment {
    Pool pool;

    function setUp() public virtual override {
        super.setUp();

        pool = new Pool(
            "Impact Pool",
            "iPOOL",
            startTime - 30 days,
            endTime + 30 days,
            domainId,
            address(evals)
        );

        evals.transferFrom(self, address(pool), evalId);
    }

    function testClaiming() public {
        claims.approve(address(pool), claimId);
        pool.claim(evalId, self);

        assertEq(pool.balanceOf(self), 42 ether);
        assertEq(evals.ownerOf(evalId), self);
        assertEq(claims.ownerOf(claimId), address(pool));
    }

    function testReclaiming() public {
        claims.approve(address(pool), claimId);
        pool.claim(evalId, self);

        evals.approve(address(pool), evalId);
        pool.reclaim(evalId, self);

        assertEq(pool.balanceOf(self), 0);
        assertEq(evals.ownerOf(evalId), address(pool));
        assertEq(claims.ownerOf(claimId), self);
    }
}
