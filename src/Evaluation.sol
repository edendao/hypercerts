// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC721.sol";

import "./interfaces/IAttestation.sol";
import "./Domain.sol";
import "./Claim.sol";

contract Evaluation is ERC721, IAttestation {
    Claim public claims;
    Domain public methods;

    constructor(
        string memory _name,
        string memory _symbol,
        address _claims,
        address _methods
    ) ERC721(_name, _symbol) {
        claims = Claim(_claims);
        methods = Domain(_methods);
    }

    function version() public pure virtual override returns (uint16) {
        return 1;
    }

    struct Metadata {
        uint16 version;
        address agent;
        uint64 startTime;
        uint64 endTime;
        uint128 impactPoints;
        uint256 claimId;
        uint256 methodId;
        string uri;
    }

    mapping(uint256 => Metadata) public metadataOf;

    function exists(uint256 id) public view virtual override returns (bool) {
        return metadataOf[id].agent != address(0);
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        require(exists(id), "NOT_MINTED");
        return metadataOf[id].uri;
    }

    event Attestation(
        address indexed agent,
        uint256 indexed methodId,
        uint256 indexed claimId,
        uint256 id,
        uint128 impactPoints,
        string uri
    );

    function attest(bytes calldata data) public payable virtual override returns (uint256 id) {
        (
            uint64 startTime,
            uint64 endTime,
            uint128 impactPoints,
            string memory evaluationURI,
            uint256 claimId,
            uint256 methodId
        ) = abi.decode(data, (uint64, uint64, uint128, string, uint256, uint256));

        require(startTime < endTime, "INVALID_TIMEFRAME");
        require(impactPoints != 0, "INVALID_POINTS");
        require(bytes(evaluationURI).length > 0, "INVALID_URI");

        require(methods.canCall(msg.sender, methodId, msg.sig), "UNAUTHORIZED");
        require(claims.exists(claimId), "INVALID_CLAIM");

        id = uint256(keccak256(bytes(evaluationURI)));
        _mint(msg.sender, id);
        emit Attestation(msg.sender, methodId, claimId, id, impactPoints, evaluationURI);

        Metadata storage c = metadataOf[id];
        c.version = version();
        c.agent = msg.sender;
        c.startTime = startTime;
        c.endTime = endTime;
        c.impactPoints = impactPoints;
        c.methodId = methodId;
        c.claimId = claimId;
        c.uri = evaluationURI;
    }

    event Withdrawn(
        address indexed agent,
        uint256 indexed methodId,
        uint256 indexed claimId,
        uint256 id
    );

    function withdraw(uint256 id) public payable virtual override {
        Metadata storage c = metadataOf[id];
        require(methods.canCall(msg.sender, c.methodId, msg.sig), "UNAUTHORIZED");

        _burn(id);
        emit Withdrawn(msg.sender, c.methodId, c.claimId, id);

        delete metadataOf[id];
    }
}
