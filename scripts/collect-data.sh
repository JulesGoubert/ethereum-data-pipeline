#! /bin/bash

set -o errexit   
set -o nounset
set -o pipefail

# directory waar data moet worden verzameld
directory=/home/linuxmint/Documents/datalinux-labs-2324-JulesGoubert/data-workflow/data
timestamp=$(date "+%Y-%m-%d-%H-%M")
# bestand waar de reponse van de Etherscan API moet in opgeslaan worden
output1="${directory}/ethereum-block-${timestamp}.json"
# bestand waar de reponse van de CoinGecko API moet in opgeslaan worden
output2="${directory}/ethereum-price-${timestamp}.json"
logfile=/home/linuxmint/Documents/datalinux-labs-2324-JulesGoubert/data-workflow/logs/log

# nagaan of jq geïnstalleerd is
if ! command -v jq &> /dev/null; then
    echo "${timestamp}:" >> "${logfile}"
    echo "Error: Required dependency jq not found" >> "${logfile}"
    exit 1
fi

# Etherescan API endpoint dat het laatste bloknummer van de Ethereum blockchain teruggeeft
block_number_endpoint="https://api.etherscan.io/api?module=proxy&action=eth_blockNumber&apikey=${ETHERSCAN_API_KEY}"
block_number=$(curl -s "${block_number_endpoint}"| jq -r ".result")
# Etherscan API endpoint dat het laatste blok van de Ethereum blockchain teruggeeft
block_endpoint="https://api.etherscan.io/api?module=proxy&action=eth_getBlockByNumber&tag=${block_number}&boolean=false&apikey=${ETHERSCAN_API_KEY}"
# CoinGecko API endpoint dat de prijs van Ethereum in USD en BTC teruggeeft
price_endpoint="https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd%2Cbtc"

echo "${timestamp}:" >> "${logfile}"
if curl --silent --output "${output1}" "${block_endpoint}"; then
    echo "Data successfully collected and saved to ${output1}" >> "${logfile}"
else
    echo "Failed to collect data from the Etherscan API" >> "${logfile}"
fi

echo "${timestamp}:" >> "${logfile}"
if curl --silent --output "${output2}" "${price_endpoint}"; then
    echo "Data successfully collected and saved to ${output2}" >> "${logfile}"
else
    echo "Failed to collect data from the CoinGecko API" >> "${logfile}"
fi

# output files read-only maken
chmod -w "${output1}" "${output2}"
