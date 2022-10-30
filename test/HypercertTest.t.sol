// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

contract HypercertTest is TestEnvironment {
    function setUp() public virtual override {
        (programId, programAuthority) = hyperspaces.create("ipfs://test-program-metadata");
        (methodId, methodAuthority) = hyperspaces.create("ipfs://test-method-metadata");
    }

    function testAttestation() public {
        claimId = certs.attest(
            abi.encode(startTime, endTime, 0, "ipfs://test-claim-metadata", 0, programId)
        );
        assertEq(certs.balanceOf(self, claimId), 1);
    }

    function testWithdrawal() public {
        claimId = certs.attest(
            abi.encode(startTime, endTime, 0, "ipfs://test-claim-metadata", 0, programId)
        );
        certs.withdraw(claimId);
        assertEq(certs.balanceOf(self, claimId), 0);
    }
}
