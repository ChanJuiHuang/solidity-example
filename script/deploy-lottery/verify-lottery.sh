source ../../.env

CONTRACT_ADDRESS=

forge verify-contract --chain-id 5 --constructor-args \
$(cast abi-encode "constructor(uint64)" 322) \
--compiler-version v0.8.16+commit.07a7930e \
--watch \
${CONTRACT_ADDRESS} src/Lottery/Lottery.sol:Lottery ${ETHERSCAN_API_KEY}
