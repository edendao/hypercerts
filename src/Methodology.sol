// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Domain} from "./mixins/Domain.sol";

contract Methodology is Domain {
    constructor(string memory _name, string memory _symbol) Domain(_name, _symbol) {}
}
