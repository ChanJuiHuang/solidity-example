source .env

IFS="/"
read -a WORDS <<< $1
IFS=""

rm -r ${PROJECT_ROOT}/broadcast/${WORDS[-1]}

forge script ${1}:${2} \
--rpc-url ${ETH_RPC_URL} \
--private-keys ${PRIVATE_KEY0} \
--private-keys ${PRIVATE_KEY0} \
--private-keys ${PRIVATE_KEY1} \
--private-keys ${PRIVATE_KEY2} \
--private-keys ${PRIVATE_KEY3} \
--private-keys ${PRIVATE_KEY4} \
--private-keys ${PRIVATE_KEY5} \
--private-keys ${PRIVATE_KEY6} \
--private-keys ${PRIVATE_KEY7} \
--private-keys ${PRIVATE_KEY8} \
--private-keys ${PRIVATE_KEY9} \
--sender ${SENDER} \
--broadcast
