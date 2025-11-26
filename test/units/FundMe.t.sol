// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundeMeTest is Test {
    FundMe fundMe;
    uint256 SEND_VALUE = 0.1 ether;
    uint256 STARTING_BALANCE = 10 ether;
    address USER = makeAddr("user"); 


    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIsOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithInsufficientETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(SEND_VALUE, amountFunded);
    }

    function testFunderIsUser() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawalWithSingleFunder() public funded {
        // Arrange
        uint256 deployerStartingBal = fundMe.getOwner().balance;
        uint256 contractStartingBal = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 deployerNewBal = fundMe.getOwner().balance;
        uint256 contractNewBal = address(fundMe).balance;

        // Assert
        assertEq(contractNewBal, 0);
        assertEq(deployerNewBal, deployerStartingBal + contractStartingBal);
    }

    function testWithdrawalWithMultipleFunders() public {
        // Arrange
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 deployerStartingBal = fundMe.getOwner().balance;
        uint256 contractStartingBal = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 deployerNewBal = fundMe.getOwner().balance;
        uint256 contractNewBal = address(fundMe).balance;

        // Assert
        assertEq(contractNewBal, 0);
        assertEq(deployerNewBal, deployerStartingBal + contractStartingBal);
    }

    function testWithdrawalWithMultipleFundersCheap() public {
        // Arrange
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 deployerStartingBal = fundMe.getOwner().balance;
        uint256 contractStartingBal = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        uint256 deployerNewBal = fundMe.getOwner().balance;
        uint256 contractNewBal = address(fundMe).balance;

        // Assert
        assertEq(contractNewBal, 0);
        assertEq(deployerNewBal, deployerStartingBal + contractStartingBal);
    }
}