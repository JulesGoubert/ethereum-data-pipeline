#! /bin/bash

set -o errexit   
set -o nounset
set -o pipefail

data_dir="../data"
csv_file="/home/linuxmint/Documents/datalinux-labs-2324-JulesGoubert/data-workflow/ethereum-data.csv"
logfile="/home/linuxmint/Documents/datalinux-labs-2324-JulesGoubert/data-workflow/logs/log"

if [ ! -f "${csv_file}" ]; then
    echo "timestamp,gasRatio,baseFeePerGas,transactionCount,usdPrice,btcPrice" > "${csv_file}"
fi

hex_to_decimal() {
    printf "%d\n" "${1}"
}

wei_to_gwei() {
    echo "scale=1;${1} / 10^9" | bc
}

process_data() {
    local file1="$1"
    local file2="$2"
    local block gasUsed gasRatio baseFeePerGas timestamp transactionCount usdPrice btcPrice

    block="$(jq .result "${file1}")"
    gasUsed="$(hex_to_decimal "$(echo "$block" | jq -r ".gasUsed")")"
    gasRatio=$(echo "scale=2;${gasUsed} / 30000000 * 100" | bc)
    baseFeePerGas="$(wei_to_gwei "$(hex_to_decimal "$(echo "$block" | jq -r ".baseFeePerGas")")")"
    timestamp="$(date -d "@$(hex_to_decimal "$(echo "$block" | jq -r ".timestamp")")" "+%Y-%m-%d %H:%M:%S")"
    transactionCount="$(echo "$block" | jq .transactions | jq length)"
    usdPrice="$(jq -r ".ethereum.usd" "${file2}")"
    btcPrice="$(jq  -r ".ethereum.btc" "${file2}")"

    echo "${timestamp},${gasRatio},${baseFeePerGas},${transactionCount},${usdPrice},${btcPrice}"
}

# nagaan of jq geïnstalleerd is
if ! command -v jq &> /dev/null; then
    echo "$(date "+%Y-%m-%d-%H-%M"):" >> "${logfile}"
    echo "Error: Required dependency jq not found" >> "${logfile}"
    exit 1
fi

# nagaan of bc geïnstalleerd is
if ! command -v bc &> /dev/null; then
    echo "$(date "+%Y-%m-%d-%H-%M"):" >> "${logfile}"
    echo "Error: Required dependency bc not found" >> "${logfile}"
    exit 1
fi

# bestanden in de data_dir sorteren op basis van de datum in hun naam
readarray -t data_list < <(find "$data_dir"/* | sort -t"-" -k3 -k4 -k5 -k6 -k7)
processed_files=processed_files.txt

# per twee itereren over de gesorteerde bestanden in de data_dir
for ((i=0; i<${#data_list[@]}; i+=2)) do
    file1="${data_list[i]}"
    file2="${data_list[i+1]}"

    if [ -f "$file1" ] && [ -f "$file2" ] ; then
        # nagaan of de files al verwerkt zijn 
        if [ ! -e "$processed_files" ] || ! grep -q "${file1}" "${processed_files}"; then
            process_data "$file1" "$file2" >> "${csv_file}"
            echo "${file1}" >> "${processed_files}"
        fi
    else 
        echo "$(date "+%Y-%m-%d-%H-%M"):" >> "${logfile}"
        echo "Error: ${file1} and/or ${file2} not found" >> "${logfile}"
    fi
done
