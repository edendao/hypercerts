// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestEnvironment.sol";

contract GroupAuthorityTest is TestEnvironment {
    function testProgramAuthority() public {
        assertEq(address(programs.authorityOf(programId)), address(programAuthority));
        address programUser = makeAddr("programUser");

        changePrank(programUser);
        vm.expectRevert("UNAUTHORIZED");
        claims.attest(abi.encode(startTime, endTime, "ipfs://claim-metadata", programId));

        changePrank(self);
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

        changePrank(self);
        r.setRoleCapability(0, address(claims), claims.withdraw.selector, true);

        changePrank(programUser);
        claims.withdraw(id);
        assertFalse(claims.exists(id));
    }

    function testMethodAuthority() public {
        assertEq(address(methods.authorityOf(methodId)), address(methodAuthority));
        claimId = claims.attest(abi.encode(startTime, endTime, "ipfs://claim-metadata", programId));
        address methodUser = makeAddr("methodUser");

        changePrank(methodUser);
        vm.expectRevert("UNAUTHORIZED");
        evals.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://eval-metadata", claimId, methodId)
        );

        changePrank(self);
        RolesAuthority r = methods.authorityOf(methodId);
        r.setRoleCapability(0, address(evals), evals.attest.selector, true);
        r.setUserRole(methodUser, 0, true);

        changePrank(methodUser);
        evalId = evals.attest(
            abi.encode(startTime, endTime, 42 ether, "ipfs://eval-metadata", claimId, methodId)
        );
        assertTrue(evals.exists(evalId));

        vm.expectRevert("UNAUTHORIZED");
        evals.withdraw(evalId);

        changePrank(self);
        r.setRoleCapability(0, address(evals), evals.withdraw.selector, true);

        changePrank(methodUser);
        evals.withdraw(evalId);
        assertFalse(evals.exists(evalId));
    }
}
