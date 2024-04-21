#! /usr/bin/python3

import pandas as pd
from matplotlib import pyplot as plt

df = pd.read_csv("../ethereum-data.csv")

timestamp = df["timestamp"]
day = timestamp[0].split(" ")[0]
time = [time.split(" ")[1] for time in timestamp]
baseFee = df["baseFeePerGas"]
gasRatio = df["gasRatio"]
transactionCount = df["transactionCount"]
usdPrice = df["usdPrice"]
btcPrice = df["btcPrice"]

def get_description(table_name):
    description = df[table_name].describe().to_frame().T.to_markdown(index=False)
    table_output_path = f"../tables/describe_{table_name}.md"

    with open(table_output_path, "w") as f:
        f.write(description + "\n")
        
for key in df.keys()[1:]:
    get_description(key)
    
def make_plot(column, ylabel, title):
    plt.figure().set_figwidth(20)
    plt.plot(time, column)
    plt.xlabel("Timestamp")
    plt.ylabel(ylabel)
    plt.title(title)
    return plt

images = "../reports/docs/images/"

plot = make_plot(baseFee, "Base Fee (Gwei)", "Base Fee over Time")
plt.savefig(f"{images}base_fee-over-time.png")

plot = make_plot(gasRatio, "Gas Ratio (gas used / gas limit) in %", "Gas Ratio over Time")
plot.axhline(50, color="red", linestyle="--", label="optimal gas ratio")
plot.legend()
plot.savefig(f"{images}gas_ratio-over-time.png")

plot = make_plot(transactionCount, "Transaction count per block", "Transactions per block over Time")
plot.savefig(f"{images}transaction_count-over-time.png")

plot = make_plot(usdPrice, "Ethereum price in USD", "Ethereum price in USD over Time")
plot.savefig(f"{images}usd_price-over-time.png")

plot = make_plot(btcPrice, "Ethereum price in BTC", "Ethereum price in BTC over Time")
plot.savefig(f"{images}btc_price-over-time.png")
