//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;





import {Script} from "forge-std/Script.sol";    // Always import this when writing a script
import {Raffle} from "../src/Raffle.sol";       // Import my contract to deploy
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "../script/Interactions.s.sol";


contract DeployRaffle is Script {

    // Step 1. Create a run() function to run the contract in question
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,                 // This constructor is essential for all of the contracts in this project
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        address link,
        uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();


        if(subscriptionId == 0) {
            // We are going to need to create a subscription!
            CreateSubscription createSubscription = new CreateSubscription();   // Calling createSubscription()
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinator,
                deployerKey
            );

            // Funding the subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinator,
                subscriptionId,
                link,
                deployerKey
            );

        }


        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
            );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            vrfCoordinator,
            subscriptionId,
            deployerKey
        );
        return (raffle, helperConfig);
    }

}

