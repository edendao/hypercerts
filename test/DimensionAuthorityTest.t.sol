// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

contract HyperspaceAuthorityTest is TestEnvironment {
    function testProgramAuthority() public {
        assertEq(address(hyperspaces.authorityOf(programId)), address(programAuthority));
        address programUser = makeAddr("programUser");

        changePrank(programUser);
        vm.expectRevert("UNAUTHORIZED");
        certs.attest(abi.encode(startTime, endTime, 0, "ipfs://claim-metadata", 0, programId));

        changePrank(self);
        RolesAuthority r = hyperspaces.authorityOf(programId);
        r.setRoleCapability(0, address(certs), certs.attest.selector, true);
        r.setUserRole(programUser, 0, true);

        changePrank(programUser);
        uint256 id = certs.attest(
            abi.encode(startTime, endTime, 0, "ipfs://claim-metadata", 0, programId)
        );
        assertEq(certs.balanceOf(programUser, id), 1);

        vm.expectRevert("UNAUTHORIZED");
        certs.withdraw(id);

        changePrank(self);
        r.setRoleCapability(0, address(certs), certs.withdraw.selector, true);

        changePrank(programUser);
        certs.withdraw(id);
        assertEq(certs.balanceOf(programUser, id), 0);
    }

    function testMethodAuthority() public {
        assertEq(address(hyperspaces.authorityOf(methodId)), address(methodAuthority));
        address methodUser = makeAddr("methodUser");

        changePrank(methodUser);
        vm.expectRevert("UNAUTHORIZED");
        certs.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://eval-metadata", claimId, methodId)
        );

        changePrank(self);
        RolesAuthority r = hyperspaces.authorityOf(methodId);
        r.setRoleCapability(0, address(certs), certs.attest.selector, true);
        r.setUserRole(methodUser, 0, true);

        changePrank(methodUser);
        uint256 id = certs.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://eval-metadata", claimId, methodId)
        );
        assertEq(certs.balanceOf(methodUser, id), 1);

        vm.expectRevert("UNAUTHORIZED");
        certs.withdraw(id);

        changePrank(self);
        r.setRoleCapability(0, address(certs), certs.withdraw.selector, true);

        changePrank(methodUser);
        certs.withdraw(id);
        assertEq(certs.balanceOf(methodUser, id), 0);
    }
}
