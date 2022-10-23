// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IAttestation {
    function version() external view returns (uint16);

    function exists(uint256 id) external view returns (bool);

    function attest(bytes calldata data) external payable returns (uint256 id);

    function withdraw(uint256 id) external payable;
}
