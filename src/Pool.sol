// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";

import "./Evaluation.sol";
import "./Domain.sol";

contract Pool is ERC20 {
    bool private _reentrancyGuard;
    uint16 public constant version = 1;
    uint64 public immutable startTime;
    uint64 public immutable endTime;
    uint256 public immutable domainId;

    Domain public immutable domain;
    Claim public immutable claims;
    Evaluation public immutable evaluations;

    constructor(
        string memory _name,
        string memory _symbol,
        uint64 _startTime,
        uint64 _endTime,
        uint256 _domainId,
        address _evaluations
    ) ERC20(_name, _symbol, 18) {
        startTime = _startTime;
        endTime = _endTime;
        domainId = _domainId;

        evaluations = Evaluation(_evaluations);
        claims = evaluations.claims();
        domain = evaluations.domain();
    }

    modifier nonReentrant() {
        require(!_reentrancyGuard, "REENTRANCY");
        _reentrancyGuard = true;
        _;
        _reentrancyGuard = false;
    }

    function claim(uint256 evaluationId, address account) public payable virtual nonReentrant {
        (
            uint16 evalVersion,
            ,
            uint64 evalStartTime,
            uint64 evalEndTime,
            uint128 evalValue,
            uint256 evalClaimId,
            uint256 evalDomainId,

        ) = evaluations.metadataOf(evaluationId);
        require(version == evalVersion, "INVALID_VERSION");
        require(domainId == evalDomainId, "INVALID_DOMAIN");
        require(startTime <= evalStartTime && evalEndTime <= endTime, "INVALID_TIMEFRAME");

        _mint(account, uint256(evalValue));

        claims.transferFrom(account, address(this), evalClaimId);
        evaluations.transferFrom(address(this), account, evaluationId);
    }

    function reclaim(uint256 evaluationId, address account) public payable virtual nonReentrant {
        (, , , , uint128 evalValue, uint256 evalClaimId, , ) = evaluations.metadataOf(evaluationId);

        _burn(account, uint256(evalValue));

        claims.transferFrom(address(this), account, evalClaimId);
        evaluations.transferFrom(account, address(this), evaluationId);
    }
}
