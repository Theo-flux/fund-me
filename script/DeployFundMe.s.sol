// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() public returns (FundMe){
        HelperConfig helperConfig = new HelperConfig();
        address activeNetworkConfigAddr = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(activeNetworkConfigAddr);
        vm.stopBroadcast();
        return fundMe;
    }
}