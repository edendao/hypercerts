// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

contract SystemGasTest is TestEnvironment {
    function testProgramCreateGas() public {
        programs.create("ipfs://program-2-metadata");
    }

    function testClaimAttestGas() public {
        claims.attest(
            abi.encode(
                block.timestamp,
                block.timestamp + 7 days,
                "ipfs://new-claim-metadata",
                programId
            )
        );
    }

    function testMethodologyCreateGas() public {
        domains.create("ipfs://methodology-2-metadata");
    }

    function testCertAttestGas() public {
        evals.attest(
            abi.encode(
                block.timestamp + 1 weeks,
                block.timestamp + 5 weeks,
                42 ether,
                "ipfs://eval-2-metadata",
                claimId,
                domainId
            )
        );
    }

    function testCertWithdrawGas() public {
        evals.withdraw(evalId);
    }
}
