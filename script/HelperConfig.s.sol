//// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

//// This contract is used to define the configuration for different networks
abstract contract CodeConstrants {
    uint256 public constant MAINNET_FORK = 1115511;
    uint256 public constant GOERLI_FORK = 5;
    uint256 public constant SEPOLIA = 11155111;
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9; // 0.000000001 LINK per gas
    int256 public MOCK_WEI_PER_UNIT_LINK = 4e15;
}

contract HelperConfig is CodeConstrants, Script {
    error HelperConfig__InvalidNetwork(uint256 chainId);
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
    }

    NetworkConfig public activeNetworkConfig;
    mapping(uint256 => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[SEPOLIA] = getSeplitConfig();
    }
    /// @dev This function is used to get the configuration for the Sepolia network
    /// @return NetworkConfig The configuration for the Sepolia network
    function getSeplitConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 0,
                callbackGasLimit: 500000
            });
    }

    /// @dev This function is used to get the configuration for the Goerli network
    /// @return NetworkConfig The configuration for the Goerli network
    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == SEPOLIA || chainId == 31337) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidNetwork(chainId);
        }
    }

    /// @dev This function is used to get the configuration for the current network
    /// @return NetworkConfig The configuration for the current network
    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    /// @dev This function is used to get the configuration for the Anvil network
    /// @return NetworkConfig The configuration for the Anvil network
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        // Deploy mocks if they don't exist
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UNIT_LINK
        );
        bytes32 gasLane = 0x0;
        uint64 subscriptionId = 0;
        uint32 callbackGasLimit = 500000;
        vm.stopBroadcast();
        activeNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinator),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: subscriptionId,
            callbackGasLimit: callbackGasLimit
        });
        return activeNetworkConfig;
    }
}
