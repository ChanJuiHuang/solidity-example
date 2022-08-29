source .env

IFS="/"
read -a WORDS <<< $1
IFS=""

rm -r ${PROJECT_ROOT}/broadcast/${WORDS[-1]}

forge script ${1}:${2} \
--rpc-url ${ETH_RPC_URL} \
--private-key ${PRIVATE_KEY} \
--broadcast
