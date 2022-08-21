source ../../.env

rm -r ${PROJECT_ROOT}/broadcast/ManipulateGoldNFT.s.sol

forge script ManipulateGoldNFT.s.sol:ManipulateGoldNFT \
--rpc-url ${ETH_RPC_URL} \
--private-key ${PRIVATE_KEY} \
--broadcast
