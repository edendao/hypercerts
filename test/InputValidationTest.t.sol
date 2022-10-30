// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

contract InputValidationTest is TestEnvironment {
    function testFailMethodologyCreateEmptyURI() public {
        hyperspaces.create("");
    }

    function testFailInvalidClaimTimeframe() public {
        certs.attest(abi.encode(uint64(0), uint64(0), 0, "ipfs://claim-1", 0, programId));
    }

    function testFailInvalidClaimURI() public {
        certs.attest(abi.encode(uint64(0), uint64(1), "", programId));
    }

    function testFailInvalidClaimProgramID() public {
        certs.attest(abi.encode(uint64(0), uint64(1), 0, "ipfs://claim-1", 0, programId + 1));
    }

    function testFailInvalidClaimDuplicateURIs() public {
        certs.attest(abi.encode(uint64(0), uint64(1), 0, "ipfs://claim-1", 0, programId));
        certs.attest(abi.encode(uint64(0), uint64(1), 0, "ipfs://claim-1", 0, programId));
    }

    function testFailInvalidCertTimeframe() public {
        certs.attest(abi.encode(uint64(0), uint64(0), 42, "ipfs://eval-1", claimId, methodId));
    }

    function testFailInvalidCertURI() public {
        certs.attest(abi.encode(uint64(0), uint64(1), 42, "", claimId, methodId));
    }

    function testFailInvalidCertDuplicateURIs() public {
        certs.attest(abi.encode(uint64(0), uint64(1), 0, "ipfs://eval-1", 0, methodId));
        certs.attest(abi.encode(uint64(0), uint64(1), 0, "ipfs://eval-1", 0, methodId));
    }
}
