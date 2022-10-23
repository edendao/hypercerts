// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import {Program} from "src/Program.sol";
import {Claim} from "src/Claim.sol";
import {Methodology} from "src/Methodology.sol";
import {Certificate} from "src/Certificate.sol";

contract InputValidationTest is Test {
    Program programs = new Program("Impact Program", "iPROGRAM");
    Claim claims = new Claim("Impact Claim", "iCLAIM", address(programs));

    Methodology methods = new Methodology("Impact Methodology", "iMETHOD");
    Certificate certs =
        new Certificate("Impact Certificate", "iCERTIFY", address(claims), address(methods));

    uint256 programId = programs.create("ipfs://test-program");
    uint256 methodId = methods.create("ipfs://test-methodology");
    uint256 claimId =
        claims.create(abi.encode(uint64(0), uint64(1), "ipfs://test-claim", programId));

    function testFailProgramCreateEmptyURI() public {
        programs.create("");
    }

    function testFailMethodologyCreateEmptyURI() public {
        methods.create("");
    }

    function testFailInvalidClaimTimeframe() public {
        claims.create(abi.encode(uint64(0), uint64(0), "ipfs://claim-1", programId));
    }

    function testFailInvalidClaimURI() public {
        claims.create(abi.encode(uint64(0), uint64(1), "", programId));
    }

    function testFailInvalidClaimProgramID() public {
        claims.create(abi.encode(uint64(0), uint64(1), "ipfs://claim-1", programId + 1));
    }

    function testFailInvalidClaimDuplicateURIs() public {
        claims.create(abi.encode(uint64(0), uint64(1), "ipfs://claim-1", programId));
        claims.create(abi.encode(uint64(0), uint64(1), "ipfs://claim-1", programId));
    }

    function testFailInvalidCertTimeframe() public {
        certs.create(abi.encode(uint64(0), uint64(0), 42, "ipfs://cert-1", claimId, methodId));
    }

    function testFailInvalidCertImpactPoints() public {
        certs.create(abi.encode(uint64(0), uint64(1), 0, "ipfs://cert-1", claimId, methodId));
    }

    function testFailInvalidCertURI() public {
        certs.create(abi.encode(uint64(0), uint64(1), 42, "", claimId, methodId));
    }

    function testFailInvalidCertDuplicateURIs() public {
        certs.create(abi.encode(uint64(0), uint64(1), "ipfs://cert-1", methodId));
        certs.create(abi.encode(uint64(0), uint64(1), "ipfs://cert-1", methodId));
    }

    function testFailInvalidCertClaimID() public {
        certs.create(abi.encode(uint64(0), uint64(1), 42, "ipfs://cert-1", claimId + 1, methodId));
    }

    function testFailInvalidCertMethodID() public {
        certs.create(abi.encode(uint64(0), uint64(1), 42, "ipfs://cert-1", claimId, methodId + 1));
    }
}
