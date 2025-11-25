// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.t.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeedAddr;
    }

    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }else if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({priceFeedAddr: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaEthConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory MainnetEthConfig = NetworkConfig({priceFeedAddr: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return MainnetEthConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){
        if (activeNetworkConfig.priceFeedAddr != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMAL, INITIAL_PRICE);
        vm.stopBroadcast();
        
        NetworkConfig memory anvilEthConfig = NetworkConfig({priceFeedAddr: address(mockV3Aggregator)});
        return anvilEthConfig;
    }
}