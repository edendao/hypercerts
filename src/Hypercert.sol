// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC1155.sol";

import "./interfaces/IAttestation.sol";
import "./Hyperspace.sol";

contract Hypercert is ERC1155, IAttestation {
    string public constant name = "HYPERCERTS";
    string public constant symbol = "HYPR";

    Hyperspace public immutable hyperspaces;

    constructor(address _hyperspaces) {
        hyperspaces = Hyperspace(_hyperspaces);
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
        uint256 hyperspaceId;
        bytes uri;
    }

    mapping(uint256 => Metadata) public metadataOf;

    function uri(uint256 id) public view virtual override returns (string memory) {
        require(metadataOf[id].agent != address(0), "NOT_MINTED");
        return string(metadataOf[id].uri);
    }

    event Attestation(
        address indexed agent,
        uint256 indexed hyperspaceId,
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
            bytes memory certURI,
            uint256 linkedId,
            uint256 hyperspaceId
        ) = abi.decode(data, (uint64, uint64, uint128, bytes, uint256, uint256));

        require(startTime < endTime, "INVALID_TIMEFRAME");
        require(certURI.length > 0, "INVALID_URI");
        require(hyperspaces.canCall(msg.sender, hyperspaceId, msg.sig), "UNAUTHORIZED");

        hypercertId = uint256(keccak256(certURI));
        _mint(msg.sender, hypercertId, 1, certURI);
        emit Attestation(msg.sender, hyperspaceId, linkedId, hypercertId, value, string(certURI));
        emit URI(string(certURI), hypercertId);

        Metadata storage c = metadataOf[hypercertId];
        require(c.agent == address(0), "ALREADY_MINTED");

        c.version = version();
        c.agent = msg.sender;
        c.startTime = startTime;
        c.endTime = endTime;
        c.value = value;
        c.hyperspaceId = hyperspaceId;
        c.linkedId = linkedId;
        c.uri = certURI;
    }

    event Withdrawn(
        address indexed agent,
        uint256 indexed hyperspaceId,
        uint256 indexed linkedId,
        uint256 hypercertId
    );

    function withdraw(uint256 hypercertId) public payable virtual override {
        Metadata storage c = metadataOf[hypercertId];
        require(hyperspaces.canCall(msg.sender, c.hyperspaceId, msg.sig), "UNAUTHORIZED");

        _burn(msg.sender, hypercertId, 1);
        emit Withdrawn(msg.sender, c.hyperspaceId, c.linkedId, hypercertId);
        emit URI("", hypercertId);

        delete metadataOf[hypercertId];
    }
}
