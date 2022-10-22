// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract Certificate is ERC721 {
    ERC721 public claims;
    ERC721 public protocols;

    constructor(
        string memory _name,
        string memory _symbol,
        address _claims,
        address _protocols
    ) ERC721(_name, _symbol) {
        claims = ERC721(_claims);
        protocols = ERC721(_protocols);
    }

    function version() public pure returns (uint16) {
        return 1;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(certificateOf[id].minter != address(0), "NOT_MINTED");
        return certificateOf[id].uri;
    }

    event Certified(
        address indexed minter,
        uint256 indexed protocolId,
        uint256 indexed claimId,
        uint256 id,
        uint128 impactPoints,
        string uri
    );

    struct CertificateData {
        uint16 version;
        address minter;
        uint64 startTime;
        uint64 endTime;
        uint128 impactPoints;
        uint256 claimId;
        uint256 protocolId;
        string uri;
    }

    mapping(uint256 => CertificateData) public certificateOf;

    function create(bytes calldata data) public payable returns (uint256) {
        (
            uint64 startTime,
            uint64 endTime,
            uint128 impactPoints,
            string memory certificateURI,
            uint256 claimId,
            uint256 protocolId
        ) = abi.decode(data, (uint64, uint64, uint128, string, uint256, uint256));
        uint256 id = uint256(keccak256(abi.encode(protocolId, claimId, startTime, endTime)));

        require(protocols.ownerOf(protocolId) == msg.sender, "UNAUTHORIZED");
        require(claims.ownerOf(claimId) != address(0), "INVALID_CLAIM");
        require(impactPoints != 0, "INVALID_POINTS");
        require(startTime < endTime, "INVALID_TIMEFRAME");
        require(bytes(certificateURI).length > 0, "INVALID_URI");

        _mint(msg.sender, id);
        emit Certified(msg.sender, protocolId, claimId, id, impactPoints, certificateURI);

        CertificateData storage c = certificateOf[id];
        c.version = version();
        c.minter = msg.sender;
        c.startTime = startTime;
        c.endTime = endTime;
        c.impactPoints = impactPoints;
        c.protocolId = protocolId;
        c.claimId = claimId;
        c.uri = certificateURI;

        return id;
    }

    function revoke(uint256 id) public payable {
        CertificateData storage c = certificateOf[id];
        require(protocols.ownerOf(c.protocolId) == msg.sender, "UNAUTHORIZED");

        _burn(id);
        emit Certified(msg.sender, c.protocolId, c.claimId, id, 0, "");

        delete certificateOf[id];
    }
}
