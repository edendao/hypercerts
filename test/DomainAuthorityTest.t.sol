// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

import {RolesAuthority} from "src/mixins/Domain.sol";

import {Program} from "src/Program.sol";
import {Claim} from "src/Claim.sol";
import {Methodology} from "src/Methodology.sol";
import {Certificate} from "src/Certificate.sol";

contract DomainAuthorityTest is Test {
    address owner = address(this);

    Program programs = new Program("Impact Program", "iPROGRAM");
    Claim claims = new Claim("Impact Claim", "iCLAIM", address(programs));

    Methodology methods = new Methodology("Impact Methodology", "iMETHOD");
    Certificate certs =
        new Certificate("Impact Certificate", "iCERTIFY", address(claims), address(methods));

    uint256 programId = programs.create("ipfs://program-metadata");
    uint256 methodId = methods.create("ipfs://methodology-metadata");

    uint64 startTime = uint64(block.timestamp - 30 days);
    uint64 endTime = uint64(block.timestamp);

    function testProgramOwnerCanAuthorizeUsers() public {
        address programUser = makeAddr("programUser");

        changePrank(programUser);
        vm.expectRevert("UNAUTHORIZED");
        claims.attest(abi.encode(startTime, endTime, "ipfs://claim-metadata", programId));

        changePrank(owner);
        RolesAuthority r = programs.authorityOf(programId);
        r.setRoleCapability(0, address(claims), claims.attest.selector, true);
        r.setUserRole(programUser, 0, true);

        changePrank(programUser);
        uint256 id = claims.attest(
            abi.encode(startTime, endTime, "ipfs://claim-metadata", programId)
        );
        assertTrue(claims.exists(id));

        vm.expectRevert("UNAUTHORIZED");
        claims.withdraw(id);

        changePrank(owner);
        r.setRoleCapability(0, address(claims), claims.withdraw.selector, true);

        changePrank(programUser);
        claims.withdraw(id);
        assertFalse(claims.exists(id));
    }

    function testMethodOwnerCanAuthorizeUsers() public {
        uint256 claimId = claims.attest(
            abi.encode(startTime, endTime, "ipfs://claim-metadata", programId)
        );
        address methodUser = makeAddr("methodUser");

        changePrank(methodUser);
        vm.expectRevert("UNAUTHORIZED");
        certs.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://cert-metadata", claimId, methodId)
        );

        changePrank(owner);
        RolesAuthority r = methods.authorityOf(methodId);
        r.setRoleCapability(0, address(certs), certs.attest.selector, true);
        r.setUserRole(methodUser, 0, true);

        changePrank(methodUser);
        uint256 id = certs.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://cert-metadata", claimId, methodId)
        );
        assertTrue(certs.exists(id));

        vm.expectRevert("UNAUTHORIZED");
        certs.withdraw(id);

        changePrank(owner);
        r.setRoleCapability(0, address(certs), certs.withdraw.selector, true);

        changePrank(methodUser);
        certs.withdraw(id);
        assertFalse(certs.exists(id));
    }
}
