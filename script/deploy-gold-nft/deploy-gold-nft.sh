source ../../.env

rm -r ${PROJECT_ROOT}/broadcast/DeployGoldNFT.s.sol

forge script DeployGoldNFT.s.sol:DeployGoldNFT \
--rpc-url ${ETH_RPC_URL} \
--private-key ${PRIVATE_KEY} \
--verify \
--etherscan-api-key ${ETHERSCAN_API_KEY} \
--broadcast
