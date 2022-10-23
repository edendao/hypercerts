// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

contract InputValidationTest is TestEnvironment {
    function testFailProgramCreateEmptyURI() public {
        programs.create("");
    }

    function testFailMethodologyCreateEmptyURI() public {
        methods.create("");
    }

    function testFailInvalidClaimTimeframe() public {
        claims.attest(abi.encode(uint64(0), uint64(0), "ipfs://claim-1", programId));
    }

    function testFailInvalidClaimURI() public {
        claims.attest(abi.encode(uint64(0), uint64(1), "", programId));
    }

    function testFailInvalidClaimProgramID() public {
        claims.attest(abi.encode(uint64(0), uint64(1), "ipfs://claim-1", programId + 1));
    }

    function testFailInvalidClaimDuplicateURIs() public {
        claims.attest(abi.encode(uint64(0), uint64(1), "ipfs://claim-1", programId));
        claims.attest(abi.encode(uint64(0), uint64(1), "ipfs://claim-1", programId));
    }

    function testFailInvalidCertTimeframe() public {
        evals.attest(abi.encode(uint64(0), uint64(0), 42, "ipfs://eval-1", claimId, methodId));
    }

    function testFailInvalidCertvalue() public {
        evals.attest(abi.encode(uint64(0), uint64(1), 0, "ipfs://eval-1", claimId, methodId));
    }

    function testFailInvalidCertURI() public {
        evals.attest(abi.encode(uint64(0), uint64(1), 42, "", claimId, methodId));
    }

    function testFailInvalidCertDuplicateURIs() public {
        evals.attest(abi.encode(uint64(0), uint64(1), "ipfs://eval-1", methodId));
        evals.attest(abi.encode(uint64(0), uint64(1), "ipfs://eval-1", methodId));
    }

    function testFailInvalidCertClaimID() public {
        evals.attest(abi.encode(uint64(0), uint64(1), 42, "ipfs://eval-1", claimId + 1, methodId));
    }

    function testFailInvalidCertMethodID() public {
        evals.attest(abi.encode(uint64(0), uint64(1), 42, "ipfs://eval-1", claimId, methodId + 1));
    }
}
