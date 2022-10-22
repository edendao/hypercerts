// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC721URIStorage} from "./mixins/ERC721URIStorage.sol";

contract Protocol is ERC721URIStorage {
    constructor(string memory _name, string memory _symbol) ERC721URIStorage(_name, _symbol) {}
}
