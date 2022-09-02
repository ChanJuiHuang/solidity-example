source .env

forge verify-contract --chain-id 5 \
--compiler-version v0.8.16+commit.07a7930e \
--watch \
${1} src/AdvanceBank/AdvanceBank.sol:AdvanceBank ${ETHERSCAN_API_KEY}
