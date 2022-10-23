// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import "src/Domain.sol";
import "src/Hypercert.sol";

contract TestEnvironment is Test {
    address self = address(this);

    Domain domains = new Domain("Hyperspace", "HYPESPACE");
    Hypercert certs = new Hypercert("Hypercert", "HYPR", address(domains));

    uint64 startTime = uint64(block.timestamp - 30 days);
    uint64 endTime = uint64(block.timestamp);

    uint256 programId;
    RolesAuthority programAuthority;

    uint256 methodId;
    RolesAuthority methodAuthority;

    function setUp() public virtual {
        (programId, programAuthority) = domains.create("ipfs://test-program-metadata");
        (methodId, methodAuthority) = domains.create("ipfs://test-method-metadata");
    }

    function testAttestation() public {
        uint256 claimId = certs.attest(
            abi.encode(startTime, endTime, 0, "ipfs://test-claim-metadata", 0, programId)
        );
        assertEq(certs.ownerOf(claimId), self);
    }

    function testWithdrawal() public {
        uint256 claimId = certs.attest(
            abi.encode(startTime, endTime, 0, "ipfs://test-claim-metadata", 0, programId)
        );
        uint256 evalId = certs.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://test-eval-metadata", claimId, methodId)
        );
        assertEq(certs.ownerOf(evalId), self);
    }
}
