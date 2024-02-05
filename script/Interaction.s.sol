// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant FUND_VALUE = 0.1 ether;

    function fundFundMe(address mostDeployedContract) public {
        vm.startBroadcast();
        FundMe(payable(mostDeployedContract)).fund{value: FUND_VALUE}();
        vm.stopBroadcast();
        console.log("FundMe funded with %s", FUND_VALUE);
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(contractAddress);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostDeployedContract) public {
        vm.startBroadcast();
        FundMe(payable(mostDeployedContract)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        WithdrawFundMe(contractAddress);
    }
}
