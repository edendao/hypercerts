// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";

import "./Domain.sol";
import "./Hypercert.sol";

contract Hyperpool is ERC20 {
    bool private _reentrancyGuard;
    uint16 public constant version = 1;
    uint64 public immutable startTime;
    uint64 public immutable endTime;

    uint256 public immutable fromDomainId;
    uint256 public immutable toDomainId;

    Hypercert public immutable hypercerts;
    Domain public immutable domains;

    constructor(
        string memory _name,
        string memory _symbol,
        uint64 _startTime,
        uint64 _endTime,
        uint256 _fromDomainId,
        uint256 _toDomainId,
        address _hypercerts
    ) ERC20(_name, _symbol, 18) {
        startTime = _startTime;
        endTime = _endTime;

        fromDomainId = _fromDomainId;
        toDomainId = _toDomainId;

        hypercerts = Hypercert(_hypercerts);
        domains = hypercerts.domains();
    }

    modifier nonReentrant() {
        require(!_reentrancyGuard, "REENTRANCY");
        _reentrancyGuard = true;
        _;
        _reentrancyGuard = false;
    }

    function claim(uint256 toHypercertId, address account) public payable virtual nonReentrant {
        (
            uint16 hypercertVersion,
            ,
            uint64 hypercertStartTime,
            uint64 hypercertEndTime,
            uint128 hypercertValue,
            uint256 fromHypercertId,
            uint256 hypercertDomainId,

        ) = hypercerts.metadataOf(toHypercertId);
        require(version == hypercertVersion, "INVALID_VERSION");
        require(fromDomainId == hypercertDomainId, "INVALID_DOMAIN");
        require(
            startTime <= hypercertStartTime && hypercertEndTime <= endTime,
            "INVALID_TIMEFRAME"
        );

        _mint(account, uint256(hypercertValue));

        hypercerts.transferFrom(account, address(this), fromHypercertId);
        hypercerts.transferFrom(address(this), account, toHypercertId);
    }

    function reclaim(uint256 toHypercertId, address account) public payable virtual nonReentrant {
        (, , , , uint128 hypercertValue, uint256 fromHypercertId, , ) = hypercerts.metadataOf(
            toHypercertId
        );

        _burn(account, uint256(hypercertValue));

        hypercerts.transferFrom(address(this), account, fromHypercertId);
        hypercerts.transferFrom(account, address(this), toHypercertId);
    }
}
