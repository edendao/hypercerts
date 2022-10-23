// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

contract InputValidationTest is TestEnvironment {
    function testFailProgramCreateEmptyURI() public {
        programs.create("");
    }

    function testFailMethodologyCreateEmptyURI() public {
        domains.create("");
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
        evals.attest(abi.encode(uint64(0), uint64(0), 42, "ipfs://eval-1", claimId, domainId));
    }

    function testFailInvalidCertvalue() public {
        evals.attest(abi.encode(uint64(0), uint64(1), 0, "ipfs://eval-1", claimId, domainId));
    }

    function testFailInvalidCertURI() public {
        evals.attest(abi.encode(uint64(0), uint64(1), 42, "", claimId, domainId));
    }

    function testFailInvalidCertDuplicateURIs() public {
        evals.attest(abi.encode(uint64(0), uint64(1), "ipfs://eval-1", domainId));
        evals.attest(abi.encode(uint64(0), uint64(1), "ipfs://eval-1", domainId));
    }

    function testFailInvalidCertClaimID() public {
        evals.attest(abi.encode(uint64(0), uint64(1), 42, "ipfs://eval-1", claimId + 1, domainId));
    }

    function testFailInvalidCertDomainId() public {
        evals.attest(abi.encode(uint64(0), uint64(1), 42, "ipfs://eval-1", claimId, domainId + 1));
    }
}
