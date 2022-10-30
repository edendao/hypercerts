// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

contract SystemGasTest is TestEnvironment {
    function testHyperspaceCreateGas() public {
        hyperspaces.create("ipfs://methodology-2-metadata");
    }

    function testCertAttestGas() public {
        certs.attest(
            abi.encode(
                block.timestamp + 1 weeks,
                block.timestamp + 5 weeks,
                42 ether,
                "ipfs://eval-2-metadata",
                claimId,
                methodId
            )
        );
    }

    function testCertWithdrawGas() public {
        certs.withdraw(evalId);
    }
}
