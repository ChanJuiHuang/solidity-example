source ../../.env

rm -r ${PROJECT_ROOT}/broadcast/DeployLottery.s.sol

forge script DeployLottery.s.sol:DeployLottery \
--rpc-url ${ETH_RPC_URL} \
--private-key ${PRIVATE_KEY} \
--verify \
--etherscan-api-key ${ETHERSCAN_API_KEY} \
--broadcast
