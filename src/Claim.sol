// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract Claim is ERC721 {
    ERC721 public programs;

    constructor(
        string memory _name,
        string memory _symbol,
        address _programs
    ) ERC721(_name, _symbol) {
        programs = ERC721(_programs);
    }

    function version() public pure returns (uint16) {
        return 1;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(metadataOf[id].minter != address(0), "NOT_MINTED");
        return metadataOf[id].uri;
    }

    event Claimed(address indexed minter, uint256 indexed programId, uint256 id);

    struct Metadata {
        uint16 version;
        address minter;
        uint64 startTime;
        uint64 endTime;
        string uri;
    }

    mapping(uint256 => Metadata) public metadataOf;

    function create(bytes calldata data) public payable returns (uint256 id) {
        (uint64 startTime, uint64 endTime, string memory claimURI, uint256 programId) = abi.decode(
            data,
            (uint64, uint64, string, uint256)
        );

        require(programs.ownerOf(programId) == msg.sender, "UNAUTHORIZED");
        require(startTime < endTime, "INVALID_TIMEFRAME");
        require(bytes(claimURI).length > 0, "INVALID_URI");

        id = uint256(keccak256(bytes(claimURI)));
        _mint(msg.sender, id);
        emit Claimed(msg.sender, programId, id);

        Metadata storage c = metadataOf[id];
        c.version = version();
        c.minter = msg.sender;
        c.startTime = startTime;
        c.endTime = endTime;
        c.uri = claimURI;
    }
}
