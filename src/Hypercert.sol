// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC721.sol";

import "./interfaces/IAttestation.sol";
import "./Domain.sol";
import "./Claim.sol";

contract Hypercert is ERC721, IAttestation {
    Domain public immutable domains;

    constructor(
        string memory _name,
        string memory _symbol,
        address _domains
    ) ERC721(_name, _symbol) {
        domains = Domain(_domains);
    }

    function version() public pure virtual override returns (uint16) {
        return 1;
    }

    struct Metadata {
        uint16 version;
        address agent;
        uint64 startTime;
        uint64 endTime;
        uint128 value;
        uint256 linkedId;
        uint256 domainId;
        string uri;
    }

    mapping(uint256 => Metadata) public metadataOf;

    function exists(uint256 id) public view virtual override returns (bool) {
        return _ownerOf[id] != address(0);
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        require(exists(id), "NOT_MINTED");
        return metadataOf[id].uri;
    }

    event Attestation(
        address indexed agent,
        uint256 indexed domainId,
        uint256 indexed linkedId,
        uint256 hypercertId,
        uint128 value,
        string uri
    );

    function attest(bytes calldata data)
        public
        payable
        virtual
        override
        returns (uint256 hypercertId)
    {
        (
            uint64 startTime,
            uint64 endTime,
            uint128 value,
            string memory uri,
            uint256 linkedId,
            uint256 domainId
        ) = abi.decode(data, (uint64, uint64, uint128, string, uint256, uint256));

        require(startTime < endTime, "INVALID_TIMEFRAME");
        require(bytes(uri).length > 0, "INVALID_URI");

        require(linkedId == 0 || exists(linkedId), "INVALID_SUBJECT");
        require(domains.canCall(msg.sender, domainId, msg.sig), "UNAUTHORIZED");

        hypercertId = uint256(keccak256(bytes(uri)));
        _mint(msg.sender, hypercertId);
        emit Attestation(msg.sender, domainId, linkedId, hypercertId, value, uri);

        Metadata storage c = metadataOf[hypercertId];
        c.version = version();
        c.agent = msg.sender;
        c.startTime = startTime;
        c.endTime = endTime;
        c.value = value;
        c.domainId = domainId;
        c.linkedId = linkedId;
        c.uri = uri;
    }

    event Withdrawn(
        address indexed agent,
        uint256 indexed domainId,
        uint256 indexed linkedId,
        uint256
    );

    function withdraw(uint256 hypercertId) public payable virtual override {
        Metadata storage c = metadataOf[hypercertId];
        require(domains.canCall(msg.sender, c.domainId, msg.sig), "UNAUTHORIZED");

        _burn(hypercertId);
        emit Withdrawn(msg.sender, c.domainId, c.linkedId, hypercertId);

        delete metadataOf[hypercertId];
    }
}
