// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import "src/Domain.sol";
import "src/Claim.sol";
import "src/Evaluation.sol";

contract TestEnvironment is Test {
    address self = address(this);

    Domain programs = new Domain("Impact Program", "iPROGRAM");
    Claim claims = new Claim("Impact Claim", "iCLAIM", address(programs));

    Domain domains = new Domain("Impact Methodology", "iMETHOD");
    Evaluation evals =
        new Evaluation("Impact Evaluation", "iCERTIFY", address(claims), address(domains));

    uint64 startTime = uint64(block.timestamp - 30 days);
    uint64 endTime = uint64(block.timestamp);

    uint256 programId;
    RolesAuthority programAuthority;
    uint256 claimId;

    uint256 domainId;
    RolesAuthority methodAuthority;
    uint256 evalId;

    function setUp() public virtual {
        (programId, programAuthority) = programs.create("ipfs://test-program-metadata");
        claimId = claims.attest(
            abi.encode(startTime, endTime, "ipfs://test-claim-metadata", programId)
        );

        (domainId, methodAuthority) = domains.create("ipfs://test-method-metadata");
        evalId = evals.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://test-eval-metadata", claimId, domainId)
        );
    }
}
