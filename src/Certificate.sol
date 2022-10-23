// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Domain} from "./mixins/Domain.sol";
import {Claim} from "./Claim.sol";

contract Certificate is ERC721 {
    Claim public claims;
    Domain public methodologies;

    constructor(
        string memory _name,
        string memory _symbol,
        address _claims,
        address _methodologies
    ) ERC721(_name, _symbol) {
        claims = Claim(_claims);
        methodologies = Domain(_methodologies);
    }

    function version() public pure returns (uint16) {
        return 1;
    }

    struct Metadata {
        uint16 version;
        address agent;
        uint64 startTime;
        uint64 endTime;
        uint128 impactPoints;
        uint256 claimId;
        uint256 methodologyId;
        string uri;
    }

    mapping(uint256 => Metadata) public metadataOf;

    function exists(uint256 id) public view returns (bool) {
        return metadataOf[id].agent != address(0);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(exists(id), "NOT_MINTED");
        return metadataOf[id].uri;
    }

    event Certified(
        address indexed agent,
        uint256 indexed methodologyId,
        uint256 indexed claimId,
        uint256 id,
        uint128 impactPoints,
        string uri
    );

    function create(bytes calldata data) public payable returns (uint256 id) {
        (
            uint64 startTime,
            uint64 endTime,
            uint128 impactPoints,
            string memory certificateURI,
            uint256 claimId,
            uint256 methodologyId
        ) = abi.decode(data, (uint64, uint64, uint128, string, uint256, uint256));

        require(methodologies.canCall(msg.sender, methodologyId, msg.sig), "UNAUTHORIZED");
        require(claims.exists(claimId), "INVALID_CLAIM");
        require(impactPoints != 0, "INVALID_POINTS");
        require(startTime < endTime, "INVALID_TIMEFRAME");
        require(bytes(certificateURI).length > 0, "INVALID_URI");

        id = uint256(keccak256(bytes(certificateURI)));
        _mint(msg.sender, id);
        emit Certified(msg.sender, methodologyId, claimId, id, impactPoints, certificateURI);

        Metadata storage c = metadataOf[id];
        c.version = version();
        c.agent = msg.sender;
        c.startTime = startTime;
        c.endTime = endTime;
        c.impactPoints = impactPoints;
        c.methodologyId = methodologyId;
        c.claimId = claimId;
        c.uri = certificateURI;
    }

    event Revoked(
        address indexed agent,
        uint256 indexed methodologyId,
        uint256 indexed claimId,
        uint256 id
    );

    function revoke(uint256 id) public payable {
        Metadata storage c = metadataOf[id];
        require(methodologies.canCall(msg.sender, c.methodologyId, msg.sig), "UNAUTHORIZED");

        _burn(id);
        emit Revoked(msg.sender, c.methodologyId, c.claimId, id);

        delete metadataOf[id];
    }
}
