// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import {RolesAuthority} from "src/mixins/Domain.sol";

import {Program} from "src/Program.sol";
import {Claim} from "src/Claim.sol";
import {Methodology} from "src/Methodology.sol";
import {Certificate} from "src/Certificate.sol";

interface IAttestation {
    function exists(uint256 id) external view returns (bool);

    function attest(bytes calldata data) external payable returns (uint256 id);

    function withdraw(uint256 id) external payable;
}

contract DomainAuthorityTest is Test {
    address owner = address(this);

    Program programs = new Program("Impact Program", "iPROGRAM");
    Claim claims = new Claim("Impact Claim", "iCLAIM", address(programs));

    Methodology methods = new Methodology("Impact Methodology", "iMETHOD");
    Certificate certs =
        new Certificate("Impact Certificate", "iCERTIFY", address(claims), address(methods));

    uint256 programId;
    RolesAuthority programAuthority;

    uint256 methodId;
    RolesAuthority methodAuthority;

    function setUp() public {
        (programId, programAuthority) = programs.create("ipfs://program-metadata");
        (methodId, methodAuthority) = methods.create("ipfs://methodology-metadata");
    }

    function testMethodAuthority() public {
        assertEq(address(methods.authorityOf(methodId)), address(methodAuthority));
        _testAuthority(IAttestation(address(methodAuthority)));
    }

    function testProgramAuthority() public {
        assertEq(address(programs.authorityOf(programId)), address(programAuthority));
        _testAuthority(IAttestation(address(programAuthority)));
    }

    function _testAuthority(IAttestation i) internal {
        address authorizedUser = makeAddr("authorizedUser");
        uint64 startTime = uint64(block.timestamp - 30 days);
        uint64 endTime = uint64(block.timestamp);

        changePrank(authorizedUser);
        vm.expectRevert("UNAUTHORIZED");
        i.attest(abi.encode(startTime, endTime, "ipfs://claim-metadata", programId));

        changePrank(owner);
        programAuthority.setRoleCapability(0, address(i), i.attest.selector, true);
        programAuthority.setUserRole(authorizedUser, 0, true);

        changePrank(authorizedUser);
        uint256 id = i.attest(abi.encode(startTime, endTime, "ipfs://claim-metadata", programId));
        assertTrue(i.exists(id));

        vm.expectRevert("UNAUTHORIZED");
        i.withdraw(id);

        changePrank(owner);
        programAuthority.setRoleCapability(0, address(i), i.withdraw.selector, true);

        changePrank(authorizedUser);
        i.withdraw(id);
        assertFalse(i.exists(id));
    }
}
