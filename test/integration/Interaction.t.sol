// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionFundme is Test {
    FundMe fundme;
    address immutable USER = makeAddr("user");
    uint256 constant FUNDING = 10 ether;
    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
       fundme = deploy.run(); 
    }

    function testUserCanFund() public {
        // hoax(USER, FUNDING);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundme));

        assert (fundme.checkAmountFunded(msg.sender) == 0.1 ether);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

        assert (address(fundme).balance == 0 ether);
    }
}