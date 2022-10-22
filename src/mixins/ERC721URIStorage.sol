// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract ERC721URIStorage is ERC721 {
    uint256 public totalSupply;
    mapping(uint256 => string) internal _tokenURI;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function tokenURI(uint256 id) public view override returns (string memory) {
        return _tokenURI[id];
    }

    function setTokenURI(uint256 id, string memory uri) public virtual {
        require(ownerOf(id) == msg.sender, "UNAUTHORIZED");
        _tokenURI[id] = uri;
    }

    function create(string memory uri) public virtual returns (uint256 id) {
        id = uint256(keccak256(bytes(uri)));
        _mint(msg.sender, id);
        _tokenURI[id] = uri;
    }

    function destroy(uint256 id) public virtual {
        require(ownerOf(id) == msg.sender, "UNAUTHORIZED");
        _burn(id);
        delete _tokenURI[id];
    }
}
