// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";

import "./Hyperspace.sol";
import "./Hypercert.sol";

contract Hyperpool is ERC20, ERC1155TokenReceiver {
    bool private _reentrancyGuard;
    uint16 public constant version = 1;
    uint64 public immutable startTime;
    uint64 public immutable endTime;

    Hypercert public immutable hypercerts;
    Hyperspace public immutable hyperspaces;

    constructor(
        string memory _name,
        string memory _symbol,
        uint64 _startTime,
        uint64 _endTime,
        address _hypercerts
    ) ERC20(_name, _symbol, 18) {
        startTime = _startTime;
        endTime = _endTime;

        hypercerts = Hypercert(_hypercerts);
        hyperspaces = hypercerts.hyperspaces();
    }

    modifier nonReentrant() {
        require(!_reentrancyGuard, "REENTRANCY");
        _reentrancyGuard = true;
        _;
        _reentrancyGuard = false;
    }

    function claim(
        uint256 toHypercertId,
        bytes calldata note,
        address account
    ) public payable virtual nonReentrant {
        (
            uint16 hypercertVersion,
            ,
            uint64 hypercertStartTime,
            uint64 hypercertEndTime,
            uint128 hypercertValue,
            uint256 linkedHypercertId,
            ,

        ) = hypercerts.metadataOf(toHypercertId);
        require(version == hypercertVersion, "INVALID_VERSION");
        require(
            startTime <= hypercertStartTime && hypercertEndTime <= endTime,
            "INVALID_TIMEFRAME"
        );

        _mint(account, uint256(hypercertValue));

        hypercerts.safeTransferFrom(account, address(this), linkedHypercertId, 1, note);
        hypercerts.safeTransferFrom(address(this), account, toHypercertId, 1, note);
    }

    function reclaim(
        uint256 toHypercertId,
        bytes calldata note,
        address account
    ) public payable virtual nonReentrant {
        (, , , , uint128 hypercertValue, uint256 linkedHypercertId, , ) = hypercerts.metadataOf(
            toHypercertId
        );

        _burn(account, uint256(hypercertValue));

        hypercerts.safeTransferFrom(address(this), account, linkedHypercertId, 1, note);
        hypercerts.safeTransferFrom(account, address(this), toHypercertId, 1, note);
    }
}
