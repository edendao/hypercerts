// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import "src/Hyperspace.sol";
import "src/Hypercert.sol";

contract TestEnvironment is Test, ERC1155TokenReceiver {
    address self = address(this);

    Hyperspace hyperspaces = new Hyperspace("Hyperspace", "HYPESPACE");
    Hypercert certs = new Hypercert(address(hyperspaces));

    uint64 startTime = uint64(block.timestamp - 30 days);
    uint64 endTime = uint64(block.timestamp);

    uint256 programId;
    RolesAuthority programAuthority;
    uint256 methodId;
    RolesAuthority methodAuthority;

    uint256 claimId;
    uint256 evalId;

    function setUp() public virtual {
        (programId, programAuthority) = hyperspaces.create("ipfs://test-program-metadata");
        (methodId, methodAuthority) = hyperspaces.create("ipfs://test-method-metadata");

        claimId = certs.attest(
            abi.encode(startTime, endTime, 0, "ipfs://test-claim-metadata", 0, programId)
        );
        evalId = certs.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://test-eval-metadata", claimId, methodId)
        );
    }
}
