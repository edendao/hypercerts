// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC721.sol";

import "./interfaces/IAttestation.sol";
import "./Domain.sol";

contract Claim is ERC721, IAttestation {
    Domain public programs;

    constructor(
        string memory _name,
        string memory _symbol,
        address _programs
    ) ERC721(_name, _symbol) {
        programs = Domain(_programs);
    }

    function version() public pure virtual override returns (uint16) {
        return 1;
    }

    struct Metadata {
        uint16 version;
        address agent;
        uint64 startTime;
        uint64 endTime;
        uint256 programId;
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

    event Attestation(address indexed agent, uint256 indexed programId, uint256 id);

    function attest(bytes calldata data) public payable virtual override returns (uint256 id) {
        (uint64 startTime, uint64 endTime, string memory claimURI, uint256 programId) = abi.decode(
            data,
            (uint64, uint64, string, uint256)
        );

        require(startTime < endTime, "INVALID_TIMEFRAME");
        require(bytes(claimURI).length > 0, "INVALID_URI");

        require(programs.canCall(msg.sender, programId, msg.sig), "UNAUTHORIZED");

        id = uint256(keccak256(bytes(claimURI)));
        _mint(msg.sender, id);
        emit Attestation(msg.sender, programId, id);

        Metadata storage c = metadataOf[id];
        c.version = version();
        c.agent = msg.sender;
        c.startTime = startTime;
        c.endTime = endTime;
        c.programId = programId;
        c.uri = claimURI;
    }

    event Withdrawn(address indexed agent, uint256 indexed programId, uint256 id);

    function withdraw(uint256 id) public payable virtual override {
        Metadata storage c = metadataOf[id];
        require(programs.canCall(msg.sender, c.programId, msg.sig), "UNAUTHORIZED");

        _burn(id);
        emit Withdrawn(c.agent, c.programId, id);

        delete metadataOf[id];
    }
}
