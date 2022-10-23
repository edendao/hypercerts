// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RolesAuthority, Authority} from "solmate/auth/authorities/RolesAuthority.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

contract Domain is ERC721 {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    mapping(uint256 => string) internal _tokenURI;

    mapping(uint256 => RolesAuthority) public authorityOf;

    function canCall(
        address user,
        uint256 domainId,
        bytes4 functionSig
    ) public view virtual returns (bool) {
        return
            user == _ownerOf[domainId] ||
            authorityOf[domainId].canCall(user, msg.sender, functionSig);
    }

    event AuthorityUpdated(uint256 indexed id, RolesAuthority authority);

    function create(string memory uri) public virtual returns (uint256 id, RolesAuthority a) {
        require(bytes(uri).length > 0, "INVALID_URI");

        id = uint256(keccak256(bytes(uri)));

        _mint(msg.sender, id);
        _tokenURI[id] = uri;

        a = new RolesAuthority(msg.sender, Authority(address(0)));

        authorityOf[id] = a;
        emit AuthorityUpdated(id, a);
    }

    modifier onlyTokenOwner(uint256 id) {
        require(_ownerOf[id] == msg.sender, "UNAUTHORIZED");
        _;
    }

    function destroy(uint256 id) public virtual onlyTokenOwner(id) {
        _burn(id);
        delete _tokenURI[id];
    }

    function setAuthority(uint256 id, RolesAuthority authority) public onlyTokenOwner(id) {
        authorityOf[id] = authority;
        emit AuthorityUpdated(id, authority);
    }

    function setTokenURI(uint256 id, string memory uri) public virtual onlyTokenOwner(id) {
        _tokenURI[id] = uri;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return _tokenURI[id];
    }
}
