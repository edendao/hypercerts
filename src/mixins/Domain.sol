// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {MultiRolesAuthority, Authority} from "solmate/auth/authorities/MultiRolesAuthority.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

contract Domain is ERC721 {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    mapping(uint256 => string) internal _tokenURI;
    mapping(uint256 => MultiRolesAuthority) public authorityOf;

    function canCall(
        address user,
        uint256 domainId,
        bytes4 functionSig
    ) public view virtual returns (bool) {
        if (user != address(0) && user == _ownerOf[domainId]) return true;

        MultiRolesAuthority a = authorityOf[domainId];
        return bytes32(0) != a.getUserRoles(user) & a.getRolesWithCapability(functionSig);
    }

    event AuthorityCreated(uint256 indexed id, MultiRolesAuthority indexed authority);

    function create(string memory uri) public virtual returns (uint256 id) {
        id = uint256(keccak256(bytes(uri)));

        _mint(msg.sender, id);
        _tokenURI[id] = uri;

        authorityOf[id] = new MultiRolesAuthority(msg.sender, Authority(address(0)));
        emit AuthorityCreated(id, authorityOf[id]);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return _tokenURI[id];
    }

    modifier onlyTokenOwner(uint256 id) {
        require(_ownerOf[id] == msg.sender, "UNAUTHORIZED");
        _;
    }

    function destroy(uint256 id) public virtual onlyTokenOwner(id) {
        _burn(id);
        delete _tokenURI[id];
    }

    function setTokenURI(uint256 id, string memory uri) public virtual onlyTokenOwner(id) {
        _tokenURI[id] = uri;
    }

    event AuthorityUpdated(uint256 indexed id, Authority authority);

    function setAuthority(uint256 id, MultiRolesAuthority authority) public onlyTokenOwner(id) {
        authorityOf[id] = authority;
        emit AuthorityUpdated(id, authority);
    }
}
