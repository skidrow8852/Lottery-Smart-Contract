-include .env

.PHONY: all test deploy

build:; forge build

test:; forge test

deploy-sepolia:; forge script script/Deploy.s.sol:DeployScript --rpc-url $(RPC_URL) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --chain-id 11155111