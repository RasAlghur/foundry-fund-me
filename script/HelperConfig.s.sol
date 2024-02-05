// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    uint8 public decimals = 8;
    int256 public initial_value = 2000e8;

    NetworkConfig public activeNetwork; 

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {

        if(block.chainid == 1) {
            activeNetwork = getMainnetConfig();
        } else if (block.chainid == 11155111) {
            activeNetwork = getSepoliaConfig();
        } else {
            activeNetwork = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaNetwork = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaNetwork;
    }
    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetNetwork = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetNetwork;

    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetwork.priceFeed != address(0)) {
            return activeNetwork;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(decimals, initial_value);
        vm.stopBroadcast();

        NetworkConfig memory anvilNetwork = NetworkConfig({priceFeed: address(mockV3Aggregator)});
        return anvilNetwork;
    }
}