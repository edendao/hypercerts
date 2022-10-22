// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract Claim is ERC721 {
    ERC721 public projects;

    constructor(
        string memory _name,
        string memory _symbol,
        address _projects
    ) ERC721(_name, _symbol) {
        projects = ERC721(_projects);
    }

    function version() public pure returns (uint16) {
        return 1;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(claimOf[id].minter != address(0), "NOT_MINTED");
        return claimOf[id].uri;
    }

    event Claimed(address indexed minter, uint256 indexed projectId, uint256 id);

    struct ClaimData {
        uint16 version;
        address minter;
        uint64 startTime;
        uint64 endTime;
        string uri;
    }

    mapping(uint256 => ClaimData) public claimOf;

    function create(bytes calldata data) public payable returns (uint256) {
        (uint64 startTime, uint64 endTime, string memory claimURI, uint256 projectId) = abi.decode(
            data,
            (uint64, uint64, string, uint256)
        );
        uint256 id = uint256(keccak256(abi.encode(claimURI)));

        require(projects.ownerOf(projectId) == msg.sender, "UNAUTHORIZED");
        require(startTime < endTime, "INVALID_TIMEFRAME");
        require(bytes(claimURI).length > 0, "INVALID_URI");

        ClaimData storage c = claimOf[id];
        c.version = version();
        c.minter = msg.sender;
        c.startTime = startTime;
        c.endTime = endTime;
        c.uri = claimURI;

        _mint(msg.sender, id);
        emit Claimed(msg.sender, projectId, id);

        return id;
    }
}
