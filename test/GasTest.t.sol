// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import {Program} from "src/Program.sol";
import {Claim} from "src/Claim.sol";
import {Methodology} from "src/Methodology.sol";
import {Certificate} from "src/Certificate.sol";

contract GasTest is Test {
    Program programs = new Program("Impact Program", "iPROGRAM");
    Claim claims = new Claim("Impact Claim", "iCLAIM", address(programs));

    Methodology methods = new Methodology("Impact Methodology", "iMETHOD");
    Certificate certs =
        new Certificate("Impact Certificate", "iCERTIFY", address(claims), address(methods));

    uint256 programId;
    uint256 methodologyId;
    uint256 claimId;
    uint256 certId;

    function setUp() public {
        programId = programs.create("ipfs://program-metadata");
        methodologyId = methods.create("ipfs://methodology-metadata");

        uint64 startTime = uint64(block.timestamp - 30 days);
        uint64 endTime = uint64(block.timestamp);

        claimId = claims.create(abi.encode(startTime, endTime, "ipfs://claim-metadata", programId));

        certId = certs.create(
            abi.encode(startTime, endTime, 42 ether, "ipfs://cert-metadata", claimId, methodologyId)
        );
    }

    function testProgramCreateGas() public {
        programs.create("ipfs://program-2-metadata");
    }

    function testCreateClaimGas() public {
        claims.create(
            abi.encode(
                block.timestamp,
                block.timestamp + 7 days,
                "ipfs://new-claim-metadata",
                programId
            )
        );
    }

    function testMethodologyCreateGas() public {
        methods.create("ipfs://methodology-2-metadata");
    }

    function testCertCreateGas() public {
        certs.create(
            abi.encode(
                block.timestamp + 1 weeks,
                block.timestamp + 5 weeks,
                42 ether,
                "ipfs://cert-2-metadata",
                claimId,
                methodologyId
            )
        );
    }

    function testCertRevokeGas() public {
        certs.revoke(certId);
    }
}
