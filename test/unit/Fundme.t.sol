// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import "../../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundme;
    HelperConfig helperConfig;

    address USER = makeAddr("user");

    uint256 valueFunded = 0.1 ether;
    uint256 START_BAL = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundme) = deployFundMe.run();
        vm.deal(USER, START_BAL);
        // console.log(fundme);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: valueFunded}();
        _;
    }

    function testMINIMUM_USD() public {
        assertEq(fundme.MINIMUM_USD(), 5 * 10 ** 18);
        //    console.log("Hello World");
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testPriceConverterVersion() public {
        // helperConfig.createAnvilConfig();
        assertEq(fundme.getVersion(), 4);
    }

    function testForFailureAtLowEthFund() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testForSuccefulFunding() public funded {
        assertEq(fundme.checkAmountFunded(USER), valueFunded);
    }

    function testWithdrawalWithLowFundsOnWithdraw() public {
        // arrange
        uint256 fundedV = 0.01 ether;
        vm.prank(USER);
        fundme.fund{value: fundedV}();

        assertEq(fundme.checkFunders(0), USER);
        assert(fundme.checkAmountFunded(USER) == fundedV);

        // act and assertion
        vm.startPrank(fundme.getOwner());
        vm.expectRevert();
        fundme.withdraw();
        vm.stopPrank();
    }
    function testWithdrawalWithLowFundsOnWithdrawWithcheapGas() public {
        // arrange
        uint256 fundedV = 0.01 ether;
        vm.prank(USER);
        fundme.fund{value: fundedV}();

        assertEq(fundme.checkFunders(0), USER);
        assert(fundme.checkAmountFunded(USER) == fundedV);

        // act and assertion
        vm.startPrank(fundme.getOwner());
        vm.expectRevert();
        fundme.withdrawWithCheapGas();
        vm.stopPrank();
    }

    function testWithdrawWithoutOwner() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();
    }

    function testWithdrawWithOwner() public funded {
        uint256 Be4WhdcontractBal = address(fundme).balance;
        uint256 Be4WhdOwnerBal = (fundme.getOwner().balance);

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        assertEq(address(fundme).balance, 0);
        assertEq(Be4WhdOwnerBal + Be4WhdcontractBal, fundme.getOwner().balance);
    }

    function testWithMultipleFundersCheapGas() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        // arrange
        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), valueFunded);
            fundme.fund{value: valueFunded}();
        }
        assert(address(fundme).balance == 1000000000000000000);

        uint256 ownerBalance = fundme.getOwner().balance;
        uint256 fundmeBalance = address(fundme).balance;

        // act
        vm.startPrank(fundme.getOwner());
        fundme.withdrawWithCheapGas();
        vm.stopPrank();

        // assertion
        assert(address(fundme).balance == 0);
        assert(ownerBalance + fundmeBalance == fundme.getOwner().balance);
    }

    function testWithMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        // arrange
        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), valueFunded);
            fundme.fund{value: valueFunded}();
        }
        assert(address(fundme).balance == 1000000000000000000);

        uint256 ownerBalance = fundme.getOwner().balance;
        uint256 fundmeBalance = address(fundme).balance;

        // act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        // assertion
        assert(address(fundme).balance == 0);
        assert(ownerBalance + fundmeBalance == fundme.getOwner().balance);
    }

    // HELPERCONFIG
}
