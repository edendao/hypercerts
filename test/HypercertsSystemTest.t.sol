// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import {Project} from "src/Project.sol";
import {Claim} from "src/Claim.sol";
import {Protocol} from "src/Protocol.sol";
import {Certificate} from "src/Certificate.sol";

contract HypercertsSystemTest is Test {
    Project projects = new Project("Impact Project", "iMPACT");
    Claim claims = new Claim("Impact Claim", "iCLAIM", address(projects));

    Protocol protocols = new Protocol("Impact Protocol", "iPROTOCOL");
    Certificate certs =
        new Certificate("Impact Certificate", "iCERTIFY", address(claims), address(protocols));

    uint256 projectId;
    uint256 protocolId;
    uint256 claimId;
    uint256 certId;

    function setUp() public {
        projectId = projects.create("ipfs://project-metadata");
        protocolId = protocols.create("ipfs://protocol-metadata");

        uint64 startTime = uint64(block.timestamp - 30 days);
        uint64 endTime = uint64(block.timestamp);

        claimId = claims.create(abi.encode(startTime, endTime, "ipfs://claim-metadata", projectId));

        certId = certs.create(
            abi.encode(startTime, endTime, 42 ether, "ipfs://cert-metadata", claimId, protocolId)
        );
    }

    function testProjectCreateGas() public {
        projects.create("ipfs://another-project-metadata");
    }

    function testCreateClaimGas() public {
        claims.create(
            abi.encode(
                block.timestamp,
                block.timestamp + 7 days,
                "ipfs://new-claim-metadata",
                projectId
            )
        );
    }

    function testProtocolCreateGas() public {
        protocols.create("ipfs://another-project-metadata");
    }

    function testCertCreateGas() public {
        certs.create(
            abi.encode(
                block.timestamp + 1 weeks,
                block.timestamp + 5 weeks,
                42 ether,
                "ipfs://cert-metadata",
                claimId,
                protocolId
            )
        );
    }

    function testCertRevokeGas() public {
        certs.revoke(certId);
    }
}
