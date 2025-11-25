// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMeFundInteraction, FundMeWithdrawInteraction} from "../../script/Interactions.s.sol";


contract InteractionsTest is Test {
    FundMe fundMe;
    uint256 SEND_VALUE = 0.1 ether;
    uint256 STARTING_BALANCE = 10 ether;
    address USER = makeAddr("user"); 


    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testFundMeFundInteraction() public {
        FundMeFundInteraction fundInteraction = new FundMeFundInteraction();
        fundInteraction.fund(address(fundMe));

        FundMeWithdrawInteraction withdrawalInteraction = new FundMeWithdrawInteraction();
        withdrawalInteraction.withdrawalInteraction(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}